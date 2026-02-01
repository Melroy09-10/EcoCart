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

  final TextEditingController _searchController =
      TextEditingController();
  String searchQuery = '';

  final List<String> categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Cold Drinks',
    'Snacks',
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

  // ================= CART =================

  CollectionReference get _cartRef {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart');
  }

  Future<void> _addToCart(ProductModel product) async {
    final ref = _cartRef.doc(product.id);
    final snap = await ref.get();

    if (snap.exists) {
      await ref.update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      await ref.set({
        'productId': product.id,
        'name': product.name,
        'image': product.images.first,
        'price': product.price,
        'unit': product.unit,
        'quantity': 1,
      });
    }
  }

  Future<void> _increaseQty(String id) async {
    await _cartRef.doc(id).update({
      'quantity': FieldValue.increment(1),
    });
  }

  Future<void> _decreaseQty(String id, int qty) async {
    if (qty <= 1) {
      await _cartRef.doc(id).delete();
    } else {
      await _cartRef.doc(id).update({
        'quantity': FieldValue.increment(-1),
      });
    }
  }

  Stream<DocumentSnapshot> _cartItemStream(String id) {
    return _cartRef.doc(id).snapshots();
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
          'EcoCart Grocery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      setState(() => searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search groceries...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.green,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black54,
                tabs: categories.map((c) => Tab(text: c)).toList(),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.shopping_cart_outlined),
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
            if (c == 'All') return _allProducts();
            return _categoryProducts(c);
          }).toList(),
        ),
      ),
    );
  }

  // ================= ALL PRODUCTS =================

  Widget _allProducts() {
    return StreamBuilder<List<ProductModel>>(
      stream: ProductService().getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }

        return _grid(snapshot.data!);
      },
    );
  }

  Widget _categoryProducts(String category) {
    return StreamBuilder<List<ProductModel>>(
      stream: ProductService().getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator());
        }

        final products = snapshot.data!
            .where((p) =>
                p.category.toLowerCase() ==
                category.toLowerCase())
            .where((p) =>
                searchQuery.isEmpty ||
                p.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList();

        return _grid(products);
      },
    );
  }

  Widget _grid(List<ProductModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (_, i) => _productTile(products[i]),
    );
  }

  // ================= PRODUCT CARD =================

  Widget _productTile(ProductModel product) {
    final bool outOfStock =
        !product.isAvailable || product.stock == 0;

    return StreamBuilder<DocumentSnapshot>(
      stream: _cartItemStream(product.id),
      builder: (context, snapshot) {
        final qty =
            snapshot.hasData && snapshot.data!.exists
                ? snapshot.data!['quantity']
                : 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔄 IMAGE SLIDER
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 140,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                    ),
                    items: product.images.map((img) {
                      return Image.network(
                        img,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // PRODUCT NAME
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              // STOCK STATUS (RELOCATED)
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color:
                        outOfStock ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    outOfStock ? 'Out of stock' : 'In stock',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: outOfStock
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // PRICE
              Text(
                '₹ ${product.price} / ${product.unit}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const Spacer(),

              // ADD / QUANTITY
              SizedBox(
                height: 42,
                width: double.infinity,
                child: outOfStock
                    ? const Center(
                        child: Text(
                          'Unavailable',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : qty == 0
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () =>
                                _addToCart(product),
                            child: const Text(
                              'ADD',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              _qtyButton(
                                icon: Icons.remove,
                                onTap: () =>
                                    _decreaseQty(
                                        product.id, qty),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .green.shade100,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  qty.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              _qtyButton(
                                icon: Icons.add,
                                onTap: qty >=
                                        product.stock
                                    ? null
                                    : () => _increaseQty(
                                        product.id),
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

  Widget _qtyButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: onTap == null
              ? Colors.grey
              : Colors.green,
        ),
      ),
    );
  }
}
