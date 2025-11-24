import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:offline_shop/data/models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ProductModel>> _articles;

  void initState() {
    super.initState();
    _articles = fetchProduct();
  }

  Future<List<ProductModel>> fetchProduct() async {
    final url = Uri.parse("https://fakestoreapi.com/products");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception("Erreur de chargement");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Produits", style: TextStyle(fontSize: 30)),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _articles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur de chargement !"));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      child: Image.network(products[index].image),
                    ),
                    title: Text(products[index].title),
                    subtitle: Text(products[index].description),
                  ),
                  Divider(),
                ],
              );
            },
            itemCount: products.length,
          );
        },
      ),
    );
  }
}
