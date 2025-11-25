class CartItemModel {
  final int id;
  final int productId;
  final String title;
  final double price;
  final String image; // URL originale
  final String? localImagePath; // Chemin local
  final int quantity;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    this.localImagePath,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      productId: json['productId'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      localImagePath: json['localImagePath'] as String?,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'price': price,
      'image': image,
      'localImagePath': localImagePath,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    int? id,
    int? productId,
    String? title,
    double? price,
    String? image,
    String? localImagePath,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      localImagePath: localImagePath ?? this.localImagePath,
      quantity: quantity ?? this.quantity,
    );
  }

  // Méthode pour obtenir l'image à afficher
  String get displayImage => localImagePath ?? image;

  bool get hasLocalImage =>
      localImagePath != null && localImagePath!.isNotEmpty;
}
