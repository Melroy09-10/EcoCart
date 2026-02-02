import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data =
                  orders[index].data() as Map<String, dynamic>;

              final totalAmount = data['totalAmount'] ?? 0;
              final paymentMethod =
                  data['paymentMethod'] ?? 'N/A';
              final orderStatus =
                  data['orderStatus'] ?? 'N/A';
              final paymentStatus =
                  data['paymentStatus'] ?? 'PENDING';

              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    '₹$totalAmount',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment: $paymentMethod'),
                      Text('Order Status: $orderStatus'),
                    ],
                  ),
                  trailing: Text(
                    paymentStatus,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: paymentStatus == 'PAID'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
