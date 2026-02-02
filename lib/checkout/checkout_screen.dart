import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'payment_method_screen.dart';
import '../orders/order_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? selectedAddressId;
  double totalAmount = 0;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _calculateTotalAmount();
  }

  /// 🔹 CALCULATE CART TOTAL
  Future<void> _calculateTotalAmount() async {
    final cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .get();

    double sum = 0;
    for (var doc in cartSnapshot.docs) {
      final data = doc.data();
      sum += (data['price'] ?? 0) * (data['quantity'] ?? 1);
    }

    if (!mounted) return;
    setState(() {
      totalAmount = sum;
    });
  }

  /// 🔹 PLACE ORDER
  Future<void> _placeOrder(String paymentMethod) async {
    if (selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an address')),
      );
      return;
    }

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart');

    final cartSnapshot = await cartRef.get();
    if (cartSnapshot.docs.isEmpty) return;

    final items = cartSnapshot.docs.map((e) => e.data()).toList();

    final addressDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(selectedAddressId!)
        .get();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('orders')
        .add({
      'items': items,
      'address': addressDoc.data() ?? {},
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentMethod == 'UPI' ? 'PAID' : 'PENDING',
      'orderStatus': 'PLACED',
      'createdAt': Timestamp.now(),
    });

    // Clear cart
    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const OrderHistoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('addresses')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Delivery Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (addresses.isEmpty)
                const Text('No address found')
              else
                ...addresses.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    child: RadioListTile<String>(
                      value: doc.id,
                      groupValue: selectedAddressId,
                      onChanged: (val) {
                        setState(() {
                          selectedAddressId = val;
                        });
                      },
                      title: Text(data['name'] ?? 'No Name'),
                      subtitle: Text(
                        '${data['address'] ?? ''}\n${data['phone'] ?? ''}',
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row('Items Total', '₹$totalAmount'),
                      const Divider(),
                      _row('Total Amount', '₹$totalAmount', bold: true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final paymentMethod = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentMethodScreen(
                          totalAmount: totalAmount,
                        ),
                      ),
                    );

                    if (paymentMethod != null) {
                      await _placeOrder(paymentMethod);
                    }
                  },
                  child: const Text('Place Order'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
