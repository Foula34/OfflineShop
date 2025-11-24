import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Map<String, dynamic>> products = [];
  final db = DatabaseService.instance;

  Future<void> loadProducts() async {
    products = await db.getProducts();
    notifyListeners();
  }

  Future<void> addProduct(
    int id,
    String title,
    double price,
    String description,
    String image,
    String category,
  ) async {
    await db.insertProduct({
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
    });

    await loadProducts();
  }
}
