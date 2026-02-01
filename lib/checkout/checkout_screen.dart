import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? selectedAddressId;

  Stream<QuerySnapshot> _addressStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .snapshots();
  }

  Future<void> _placeOrder() async {
    if (selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an address')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

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
        .doc(selectedAddressId)
        .get();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('orders')
        .add({
      'items': items,
      'address': addressDoc.data(),
      'createdAt': Timestamp.now(),
      'status': 'Placed',
    });

    for (var doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }

    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _addressStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: addresses.isEmpty
                    ? const Center(
                        child: Text('No address found. Add one.'),
                      )
                    : ListView(
                        children: addresses.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return RadioListTile(
                            value: doc.id,
                            groupValue: selectedAddressId,
                            onChanged: (value) {
                              setState(() {
                                selectedAddressId = value;
                              });
                            },
                            title: Text(data['name']),
                            subtitle: Text(
                              '${data['address']}\n${data['phone']}',
                            ),
                          );
                        }).toList(),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/address');
                        },
                        child: const Text('Add New Address'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _placeOrder,
                        child: const Text('Place Order'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
