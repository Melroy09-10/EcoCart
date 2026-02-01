import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../firebase/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_web_wrapper.dart';
import '../cart/cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  /// Store selected size per product
  final Map<String, String> _selectedSizes = {};

  final List<String> categories = [
    'All',
    'Men',
    'Women',
    'Kids',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ================= FIRESTORE CART =================

  CollectionReference get _cartRef {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart');
  }

  Future<void> _addToCart(ProductModel product, String size) async {
    final docId = '${product.id}_$size';
    final ref = _cartRef.doc(docId);
    final snap = await ref.get();

    if (snap.exists) {
      ref.update({'quantity': FieldValue.increment(1)});
    } else {
      ref.set({
        'productId': product.id,
        'name': product.name,
        'image': product.images.first,
        'price': product.price,
        'size': size,
        'quantity': 1,
      });
    }
  }

  Future<void> _increaseQty(String docId) async {
    _cartRef.doc(docId).update({
      'quantity': FieldValue.increment(1),
    });
  }

  Future<void> _decreaseQty(String docId, int qty) async {
    final ref = _cartRef.doc(docId);
    if (qty <= 1) {
      ref.delete();
    } else {
      ref.update({'quantity': FieldValue.increment(-1)});
    }
  }

  Stream<DocumentSnapshot> _cartItemStream(String docId) {
    return _cartRef.doc(docId).snapshots();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'EcoCart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) {
                    setState(() => searchQuery = v.toLowerCase());
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.orange,
                labelColor: Colors.orange,
                unselectedLabelColor: Colors.black54,
                tabs: categories.map((c) => Tab(text: c)).toList(),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: AppWebWrapper(
        child: TabBarView(
          controller: _tabController,
          children: categories.map((c) {
            if (c == 'All') return _allProductsSectionView();
            return _categoryGrid(c);
          }).toList(),
        ),
      ),
    );
  }

  // ================= ALL PRODUCTS =================

  Widget _allProductsSectionView() {
    return StreamBuilder<List<ProductModel>>(
      stream: ProductService().getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allProducts = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(12),
          children: categories.where((c) => c != 'All').map((category) {
            final sectionProducts = allProducts
                .where((p) =>
                    p.category.toLowerCase() ==
                    category.toLowerCase())
                .where((p) =>
                    searchQuery.isEmpty ||
                    p.name.toLowerCase().contains(searchQuery))
                .toList();

            if (sectionProducts.isEmpty) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: sectionProducts.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.45,
                  ),
                  itemBuilder: (_, i) =>
                      _productTile(sectionProducts[i]),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _categoryGrid(String category) {
    return StreamBuilder<List<ProductModel>>(
      stream: ProductService().getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!
            .where((p) =>
                p.category.toLowerCase() ==
                category.toLowerCase())
            .where((p) =>
                searchQuery.isEmpty ||
                p.name.toLowerCase().contains(searchQuery))
            .toList();

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.45,
          ),
          itemBuilder: (_, i) => _productTile(products[i]),
        );
      },
    );
  }

  // ================= PRODUCT TILE =================

  Widget _productTile(ProductModel product) {
    _selectedSizes.putIfAbsent(
      product.id,
      () => product.sizes.entries
          .firstWhere(
            (e) => e.value > 0,
            orElse: () => product.sizes.entries.first,
          )
          .key,
    );

    final selectedSize = _selectedSizes[product.id]!;
    final stock = product.sizes[selectedSize] ?? 0;
    final docId = '${product.id}_$selectedSize';

    return StreamBuilder<DocumentSnapshot>(
      stream: _cartItemStream(docId),
      builder: (context, snapshot) {
        final qty =
            snapshot.hasData && snapshot.data!.exists
                ? snapshot.data!['quantity']
                : 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 1,
                    enableInfiniteScroll: false,
                  ),
                  items: product.images
                      .map((img) => Image.network(
                            img,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '₹ ${product.price}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              SizeSelector(
                sizes: product.sizes,
                selectedSize: selectedSize,
                onChanged: (size) {
                  setState(() {
                    _selectedSizes[product.id] = size;
                  });
                },
              ),

              const Spacer(),

              SizedBox(
                height: 42,
                width: double.infinity,
                child: stock == 0
                    ? const Center(
                        child: Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : qty == 0
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            onPressed: () =>
                                _addToCart(product, selectedSize),
                            child: const Text('ADD'),
                          )
                        : Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: Colors.orange),
                                onPressed: () =>
                                    _decreaseQty(docId, qty),
                              ),

                              // ✅ QUANTITY PILL (YOU ASKED FOR THIS)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.orange.shade100,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  qty.toString(),
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: Colors.orange),
                                onPressed: qty >= stock
                                    ? null
                                    : () =>
                                        _increaseQty(docId),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ================= SIZE SELECTOR =================

class SizeSelector extends StatelessWidget {
  final Map<String, int> sizes;
  final String selectedSize;
  final ValueChanged<String> onChanged;

  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: sizes.entries.map((entry) {
        final size = entry.key;
        final stock = entry.value;
        final isSelected = size == selectedSize;

        return GestureDetector(
          onTap: stock == 0 ? null : () => onChanged(size),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.orange
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              size,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: stock == 0
                    ? Colors.grey
                    : isSelected
                        ? Colors.white
                        : Colors.black,
                decoration: stock == 0
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
