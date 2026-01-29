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

  // ================= FIRESTORE =================

  factory ProductModel.fromMap(
      Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      category: map['category'],
      images: List<String>.from(map['images']),
      sizes: Map<String, int>.from(map['sizes']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'images': images,
      'sizes': sizes,
    };
  }

  // ================= LOCAL STORAGE (CART) =================

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
