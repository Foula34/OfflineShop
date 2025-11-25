import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:offline_shop/data/models/product_model.dart';
import 'package:offline_shop/presentation/pages/cart_screen.dart';
import 'package:offline_shop/presentation/pages/product_detail_screen.dart';
import 'package:offline_shop/presentations/widgets/cached_image_widget.dart';
import 'package:provider/provider.dart';
import 'package:offline_shop/providers/product_provider.dart';
import 'package:offline_shop/providers/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingFromApi = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    await cartProvider.loadCartItems();
    await productProvider.loadProducts();

    if (productProvider.products.isEmpty) {
      await _fetchProductsFromApi();
    }
  }

  Future<void> _fetchProductsFromApi() async {
    setState(() {
      _isLoadingFromApi = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse("https://fakestoreapi.com/products");
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final List<ProductModel> products = data
            .map((e) => ProductModel.fromJson(e))
            .toList();

        final provider = Provider.of<ProductProvider>(context, listen: false);
        await provider.addProducts(products);

        setState(() {
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = "Erreur de chargement: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Mode offline: Impossible de charger de nouveaux produits";
      });
    } finally {
      setState(() {
        _isLoadingFromApi = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Produits",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoadingFromApi ? null : _fetchProductsFromApi,
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.products.isEmpty && !_isLoadingFromApi) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Aucun produit disponible",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _fetchProductsFromApi,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Charger les produits"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (_isLoadingFromApi)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.blue.shade100,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text("Synchronisation en cours..."),
                    ],
                  ),
                ),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.orange.shade100,
                  width: double.infinity,
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_errorMessage!)),
                    ],
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.65,
                  ),
                  padding: const EdgeInsets.all(10),
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: CachedImageWidget(
                                  localImagePath: product.localImagePath,
                                  networkImageUrl: product.image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Consumer<CartProvider>(
                                          builder: (context, cartProvider, child) {
                                            final isInCart = cartProvider
                                                .isInCart(product.id);
                                            return IconButton(
                                              icon: Icon(
                                                isInCart
                                                    ? Icons.shopping_cart
                                                    : Icons.add_shopping_cart,
                                                color: isInCart
                                                    ? Colors.green
                                                    : Colors.blue,
                                              ),
                                              onPressed: () async {
                                                await cartProvider.addToCart(
                                                  product.id,
                                                  product.title,
                                                  product.price,
                                                  product.image,
                                                  localImagePath:
                                                      product.localImagePath,
                                                );

                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '${product.title} ajouté au panier',
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 2,
                                                      ),
                                                      action: SnackBarAction(
                                                        label: 'Voir',
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const CartScreen(),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
