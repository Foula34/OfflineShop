import 'package:flutter/material.dart';
import '../data/models/cart_item_model.dart';
import '../services/database_service.dart';
import '../services/image_cache_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItemModel> _cartItems = [];
  final db = DatabaseService.instance;
  final imageCache = ImageCacheService.instance;

  List<CartItemModel> get cartItems => _cartItems;

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  Future<void> loadCartItems() async {
    try {
      final cartData = await db.getCartItems();
      _cartItems = cartData
          .map((data) => CartItemModel.fromJson(data))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement du panier: $e');
    }
  }

  Future<void> addToCart(
    int productId,
    String title,
    double price,
    String image, {
    String? localImagePath,
  }) async {
    try {
      final existingItem = await db.getCartItemByProductId(productId);

      if (existingItem != null) {
        final currentQuantity = existingItem['quantity'] as int;
        await db.updateCartItemQuantity(productId, currentQuantity + 1);
      } else {
        // Télécharger l'image si elle n'existe pas localement
        String? imagePath = localImagePath;
        if (imagePath == null || imagePath.isEmpty) {
          imagePath = await imageCache.downloadAndSaveImage(image, productId);
        }

        await db.insertCartItem({
          'productId': productId,
          'title': title,
          'price': price,
          'image': image,
          'localImagePath': imagePath,
          'quantity': 1,
        });
      }

      await loadCartItems();
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e');
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      await db.deleteCartItem(productId);
      await loadCartItems();
    } catch (e) {
      print('Erreur lors de la suppression du panier: $e');
    }
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(productId);
      } else {
        await db.updateCartItemQuantity(productId, quantity);
        await loadCartItems();
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la quantité: $e');
    }
  }

  Future<void> incrementQuantity(int productId) async {
    try {
      final existingItem = await db.getCartItemByProductId(productId);
      if (existingItem != null) {
        final currentQuantity = existingItem['quantity'] as int;
        await updateQuantity(productId, currentQuantity + 1);
      }
    } catch (e) {
      print('Erreur lors de l\'incrémentation: $e');
    }
  }

  Future<void> decrementQuantity(int productId) async {
    try {
      final existingItem = await db.getCartItemByProductId(productId);
      if (existingItem != null) {
        final currentQuantity = existingItem['quantity'] as int;
        await updateQuantity(productId, currentQuantity - 1);
      }
    } catch (e) {
      print('Erreur lors de la décrémentation: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await db.clearCart();
      _cartItems = [];
      notifyListeners();
    } catch (e) {
      print('Erreur lors du vidage du panier: $e');
    }
  }

  bool isInCart(int productId) {
    return _cartItems.any((item) => item.productId == productId);
  }

  int getItemQuantity(int productId) {
    final item = _cartItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItemModel(
        id: 0,
        productId: 0,
        title: '',
        price: 0,
        image: '',
        quantity: 0,
      ),
    );
    return item.quantity;
  }
}
