import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final _db = FirebaseFirestore.instance.collection('products');

  Stream<List<ProductModel>> getProducts() {
    return _db.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> addProduct(ProductModel product) async {
    await _db.add(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _db.doc(id).delete();
  }
}
