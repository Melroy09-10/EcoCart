import 'package:flutter/material.dart';
import '../../firebase/order_service.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: StreamBuilder(
        stream: OrderService().getOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final order = docs[i];
              return ListTile(
                title: Text('₹ ${order['total']}'),
                subtitle: Text(order['createdAt']),
              );
            },
          );
        },
      ),
    );
  }
}
