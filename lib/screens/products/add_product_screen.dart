import 'package:flutter/material.dart';

import '../../firebase/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/app_drawer.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _service = ProductService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();
  final TextEditingController imageUrlController =
      TextEditingController();

  final List<String> imageUrls = [];

  String category = 'Vegetables';
  String unit = 'kg';
  bool isAvailable = true;

  @override
  void initState() {
    super.initState();

    // 🔥 PREFILL WHEN EDITING
    if (widget.product != null) {
      final p = widget.product!;
      nameController.text = p.name;
      priceController.text = p.price.toString();
      stockController.text = p.stock.toString();
      descriptionController.text = p.description;
      category = p.category;
      unit = p.unit;
      isAvailable = p.isAvailable;
      imageUrls.addAll(p.images);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Add Product' : 'Edit Product',
        ),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(nameController, 'Product Name'),

              _field(
                priceController,
                'Price',
                keyboard: TextInputType.number,
              ),

              _field(
                stockController,
                'Stock Quantity',
                keyboard: TextInputType.number,
              ),

              DropdownButtonFormField(
                value: category,
                decoration:
                    const InputDecoration(labelText: 'Category'),
                items: [
                  'Vegetables',
                  'Fruits',
                  'Cold Drinks',
                  'Snacks',
                ]
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => category = v!),
              ),

              DropdownButtonFormField(
                value: unit,
                decoration:
                    const InputDecoration(labelText: 'Unit'),
                items: ['kg', 'litre', 'piece']
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(u),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => unit = v!),
              ),

              SwitchListTile(
                value: isAvailable,
                title: const Text('Available for Sale'),
                onChanged: (v) =>
                    setState(() => isAvailable = v),
              ),

              const SizedBox(height: 16),

              _field(
                descriptionController,
                'Description',
              ),

              const SizedBox(height: 20),
              const Text(
                'Product Images (URLs)',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: imageUrlController,
                      decoration:
                          const InputDecoration(labelText: 'Image URL'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _addImageUrl,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (imageUrls.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: imageUrls.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (_, i) {
                    final url = imageUrls[i];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => imageUrls.removeAt(i)),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  child: Text(
                    widget.product == null
                        ? 'Add Product'
                        : 'Update Product',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
        validator: (v) =>
            v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  void _addImageUrl() {
    final url = imageUrlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      imageUrls.add(url);
      imageUrlController.clear();
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one image')),
      );
      return;
    }

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: nameController.text.trim(),
      price: double.parse(priceController.text),
      category: category,
      images: imageUrls,
      stock: int.parse(stockController.text),
      unit: unit,
      description: descriptionController.text.trim(),
      isAvailable: isAvailable,
    );

    if (widget.product == null) {
      await _service.addProduct(product);
    } else {
      await _service.updateProduct(product);
    }

    if (mounted) Navigator.pop(context);
  }
}
