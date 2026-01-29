import 'package:flutter/material.dart';

import '../../firebase/product_service.dart';
import '../../models/product_model.dart';
import 'add_product_screen.dart';

class ProductListScreen extends StatelessWidget {
  ProductListScreen({super.key});

  final ProductService _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddProductScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: product.images.isNotEmpty
                      ? Image.network(
                          product.images.first,
                          width: 55,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text(
                    product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '₹ ${product.price}\n${product.category}',
                  ),
                  isThreeLine: true,

                  /// ⬇️ EDIT + DELETE MENU
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddProductScreen(
                              product: product, // 👈 EDIT MODE
                            ),
                          ),
                        );
                      }

                      if (value == 'delete') {
                        final confirm =
                            await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title:
                                const Text('Delete Product'),
                            content: const Text(
                                'Are you sure you want to delete this product?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(
                                      color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await _productService
                              .deleteProduct(product.id);
                        }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
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
