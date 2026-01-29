import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference get users => _db.collection('users');
  CollectionReference get products => _db.collection('products');
  CollectionReference get carts => _db.collection('carts');

  // Add user to Firestore
  Future<void> addUser({
    required String uid,
    required String email,
  }) async {
    await users.doc(uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
