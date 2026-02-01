class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final List<String> images;

  // 🛒 GROCERY FIELDS
  final int stock;
  final String unit; // kg / litre / piece
  final String description;
  final bool isAvailable;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.images,
    required this.stock,
    required this.unit,
    required this.description,
    required this.isAvailable,
  });

  // ================= FIRESTORE =================
  // 🔥 SAFE AGAINST OLD DATA (NO CRASH)
  factory ProductModel.fromMap(
      Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),

      // ✅ SAFE FALLBACKS
      stock: map['stock'] ?? 0,
      unit: map['unit'] ?? 'piece',
      description: map['description'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'images': images,
      'stock': stock,
      'unit': unit,
      'description': description,
      'isAvailable': isAvailable,
    };
  }

  // ================= LOCAL STORAGE (CART) =================
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      stock: json['stock'] ?? 0,
      unit: json['unit'] ?? 'piece',
      description: json['description'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'images': images,
      'stock': stock,
      'unit': unit,
      'description': description,
      'isAvailable': isAvailable,
    };
  }
}
