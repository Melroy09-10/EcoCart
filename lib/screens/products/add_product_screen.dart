import 'package:flutter/material.dart';

import '../../firebase/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/app_drawer.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product; // ✅ IMPORTANT

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _service = ProductService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController =
      TextEditingController();

  final List<String> imageUrls = [];

  String category = 'Men';

  final Map<String, TextEditingController> sizeControllers = {
    'S': TextEditingController(),
    'M': TextEditingController(),
    'L': TextEditingController(),
    'XL': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();

    // 🔥 PREFILL WHEN EDITING
    if (widget.product != null) {
      nameController.text = widget.product!.name;
      priceController.text =
          widget.product!.price.toString();
      category = widget.product!.category;
      imageUrls.addAll(widget.product!.images);

      widget.product!.sizes.forEach((k, v) {
        sizeControllers[k]?.text = v.toString();
      });
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

              DropdownButtonFormField(
                value: category,
                decoration:
                    const InputDecoration(labelText: 'Category'),
                items: ['Men', 'Women', 'Kids', 'Accessories']
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => category = v!),
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

              // 🔥 IMAGE PREVIEW
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
                  itemBuilder: (context, index) {
                    final url = imageUrls[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(
                                () => imageUrls.removeAt(index),
                              );
                            },
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

              const SizedBox(height: 20),

              const Text(
                'Sizes & Quantity',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              ...sizeControllers.entries.map(
                (e) => _field(
                  e.value,
                  '${e.key} Quantity',
                  keyboard: TextInputType.number,
                ),
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

  void _addImageUrl() {
    final url = imageUrlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      imageUrls.add(url);
      imageUrlController.clear();
    });
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

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one image')),
      );
      return;
    }

    final sizes = <String, int>{};
    sizeControllers.forEach((k, v) {
      sizes[k] = int.parse(v.text);
    });

    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: nameController.text.trim(),
      price: double.parse(priceController.text),
      category: category,
      sizes: sizes,
      images: imageUrls,
    );

    if (widget.product == null) {
      await _service.addProduct(product);
    } else {
      await _service.updateProduct(product);
    }

    if (mounted) Navigator.pop(context);
  }
}
