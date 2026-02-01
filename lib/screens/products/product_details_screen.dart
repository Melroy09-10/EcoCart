import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_drawer.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final int stock = widget.product.stock;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),

      // ✅ SIDEBAR
      drawer: AppDrawer(),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔥 IMAGE SLIDER
            CarouselSlider(
              options: CarouselOptions(
                height: 260,
                viewportFraction: 1,
                enableInfiniteScroll: false,
              ),
              items: widget.product.images
                  .map(
                    (url) => Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                  .toList(),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '₹ ${widget.product.price} / ${widget.product.unit}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (widget.product.description.isNotEmpty)
                    Text(
                      widget.product.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 🔹 STOCK INFO
                  Text(
                    stock > 0
                        ? 'Available stock: $stock ${widget.product.unit}'
                        : 'Out of stock',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: stock > 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 QUANTITY SELECTOR
                  const Text(
                    'Quantity',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: quantity < stock
                            ? () => setState(() => quantity++)
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 🔥 ADD TO CART
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (!widget.product.isAvailable ||
                              stock == 0)
                          ? null
                          : () {
                              for (int i = 0;
                                  i < quantity;
                                  i++) {
                                cart.add(widget.product);
                              }

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Added to cart'),
                                ),
                              );
                            },
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
