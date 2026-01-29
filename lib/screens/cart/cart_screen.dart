import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../firebase/order_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return ListTile(
                        leading: Image.network(
                          item.product.images.first,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.product.name),
                        subtitle: Text(
                          'Size: ${item.size}  •  ₹${item.product.price}',
                        ),
                        trailing: Text(
                          'x${item.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // TOTAL + CHECKOUT
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹ ${cart.totalPrice}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            final orderItems = cart.items
                                .map(
                                  (e) => {
                                    'productId': e.product.id,
                                    'name': e.product.name,
                                    'price': e.product.price,
                                    'size': e.size,
                                    'quantity': e.quantity,
                                  },
                                )
                                .toList();

                            await OrderService().placeOrder(
                              orderItems,
                              cart.totalPrice,
                            );

                            cart.clear();

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Order placed successfully'),
                              ),
                            );

                            Navigator.pop(context);
                          },
                          child: const Text('PLACE ORDER'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
