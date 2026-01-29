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
  late String selectedSize;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.product.sizes.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final int stock = widget.product.sizes[selectedSize] ?? 0;

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
                    '₹ ${widget.product.price}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 SIZE SELECTION
                  const Text(
                    'Select Size',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    children:
                        widget.product.sizes.entries.map((entry) {
                      final size = entry.key;
                      final qty = entry.value;

                      return ChoiceChip(
                        label: Text('$size ($qty)'),
                        selected: selectedSize == size,
                        onSelected: qty == 0
                            ? null
                            : (_) {
                                setState(() {
                                  selectedSize = size;
                                  quantity = 1;
                                });
                              },
                      );
                    }).toList(),
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
                      const SizedBox(width: 10),
                      Text('Available: $stock'),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 🔥 ADD TO CART
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: stock == 0
                          ? null
                          : () {
                              // ✅ CORRECT METHOD
                              for (int i = 0; i < quantity; i++) {
                                cart.add(widget.product, selectedSize);
                              }

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Added to cart'),
                                ),
                              );
                            },
                      child: const Text('Add to Cart'),
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
