class ProductModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image; // URL originale
  final String? localImagePath; // Chemin local de l'image

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.localImagePath,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      localImagePath: json['localImagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'localImagePath': localImagePath,
    };
  }

  ProductModel copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? image,
    String? localImagePath,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      image: image ?? this.image,
      localImagePath: localImagePath ?? this.localImagePath,
    );
  }

  // Méthode pour obtenir l'image à afficher (locale si disponible, sinon URL)
  String get displayImage => localImagePath ?? image;

  // Vérifier si l'image est disponible localement
  bool get hasLocalImage =>
      localImagePath != null && localImagePath!.isNotEmpty;
}
