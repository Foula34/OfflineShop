import 'package:flutter/material.dart';
import '../data/models/product_model.dart';
import '../services/database_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  final db = DatabaseService.instance;
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
      await db.insertProduct({
        'id': id,
        'title': title,
        'price': price,
        'description': description,
        'category': category,
        'image': image,
      });

      await loadProducts();
    } catch (e) {
      print('Erreur lors de l\'ajout du produit: $e');
    }
  }

  Future<void> addProducts(List<ProductModel> products) async {
    try {
      for (var product in products) {
        await db.insertProduct({
          'id': product.id,
          'title': product.title,
          'price': product.price,
          'description': product.description,
          'category': product.category,
          'image': product.image,
        });
      }
      await loadProducts();
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
}
