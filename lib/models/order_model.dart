class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final List<String> images;
  final Map<String, int> sizes;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.images,
    required this.sizes,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      images: List<String>.from(json['images']),
      sizes: Map<String, int>.from(json['sizes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'images': images,
      'sizes': sizes,
    };
  }
}
