import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final CollectionReference _db =
      FirebaseFirestore.instance.collection('products');

  // ================= GET PRODUCTS =================

  Stream<List<ProductModel>> getProducts() {
    return _db.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // ================= ADD PRODUCT =================
  // Uses auto-generated document ID

  Future<void> addProduct(ProductModel product) async {
    await _db.add(product.toMap());
  }

  // ================= UPDATE PRODUCT =================

  Future<void> updateProduct(ProductModel product) async {
    await _db.doc(product.id).update(product.toMap());
  }

  // ================= DELETE PRODUCT =================

  Future<void> deleteProduct(String id) async {
    await _db.doc(id).delete();
  }
}
