import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../services/database_service.dart';
import '../services/image_cache_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  final db = DatabaseService.instance;
  final imageCache = ImageCacheService.instance;
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final productsData = await db.getProducts();
      _products = productsData
          .map((data) => ProductModel.fromJson(data))
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(
    int id,
    String title,
    double price,
    String description,
    String image,
    String category,
  ) async {
    try {
      // Télécharger l'image
      final localImagePath = await imageCache.downloadAndSaveImage(image, id);

      await db.insertProduct({
        'id': id,
        'title': title,
        'price': price,
        'description': description,
        'category': category,
        'image': image,
        'localImagePath': localImagePath,
      });

      await loadProducts();
    } catch (e) {
      print('Erreur lors de l\'ajout du produit: $e');
    }
  }

  Future<void> addProducts(List<ProductModel> products) async {
    try {
      for (var product in products) {
        // Télécharger l'image de chaque produit
        final localImagePath = await imageCache.downloadAndSaveImage(
          product.image,
          product.id,
        );

        await db.insertProduct({
          'id': product.id,
          'title': product.title,
          'price': product.price,
          'description': product.description,
          'category': product.category,
          'image': product.image,
          'localImagePath': localImagePath,
        });
      }
      await loadProducts();
      print('✅ ${products.length} produits ajoutés avec images');
    } catch (e) {
      print('Erreur lors de l\'ajout des produits: $e');
    }
  }

  Future<void> clearProducts() async {
    try {
      await db.deleteAllProducts();
      _products = [];
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la suppression des produits: $e');
    }
  }

  // Nouvelle méthode pour nettoyer le cache d'images
  Future<void> clearImageCache() async {
    try {
      await imageCache.clearAllImages();
      print('✅ Cache d\'images nettoyé');
    } catch (e) {
      print('Erreur lors du nettoyage du cache: $e');
    }
  }

  // Méthode pour obtenir la taille du cache
  Future<double> getCacheSizeMB() async {
    return await imageCache.getCacheSizeMB();
  }
}
