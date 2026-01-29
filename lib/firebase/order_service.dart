import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> placeOrder(
      List<Map<String, dynamic>> items, double total) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('orders')
        .add({
      'items': items,
      'total': total,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<QuerySnapshot> getOrders() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
