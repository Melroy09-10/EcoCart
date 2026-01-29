import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

import '../../firebase/product_service.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_drawer.dart';
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

  /// ✅ STORE SELECTED SIZE PER PRODUCT
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

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

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
              // 🔍 SEARCH BAR
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
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

              // 🧭 TAB BAR
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
          Stack(
            children: [
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
              if (cart.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      cart.totalItems.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      // ================= BODY =================
      body: TabBarView(
        controller: _tabController,
        children: categories.map((c) {
          if (c == 'All') {
            return _allProductsSectionView();
          }
          return _categoryGrid(c);
        }).toList(),
      ),
    );
  }

  // ================= ALL PAGE (SECTION WISE) =================
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
          children: categories
              .where((c) => c != 'All')
              .map((category) {
            List<ProductModel> sectionProducts = allProducts
                .where((p) =>
                    p.category.toLowerCase() ==
                    category.toLowerCase())
                .toList();

            if (searchQuery.isNotEmpty) {
              sectionProducts = sectionProducts
                  .where((p) =>
                      p.name.toLowerCase().contains(searchQuery))
                  .toList();
            }

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

  // ================= CATEGORY PAGE =================
  Widget _categoryGrid(String category) {
    return StreamBuilder<List<ProductModel>>(
      stream: ProductService().getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<ProductModel> products = snapshot.data!
            .where((p) =>
                p.category.toLowerCase() ==
                category.toLowerCase())
            .toList();

        if (searchQuery.isNotEmpty) {
          products = products
              .where((p) =>
                  p.name.toLowerCase().contains(searchQuery))
              .toList();
        }

        if (products.isEmpty) {
          return const Center(child: Text('No products found'));
        }

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
    final cart = context.watch<CartProvider>();

    /// ✅ SAFE DEFAULT SIZE
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

    final cartItem = cart.items.firstWhere(
      (e) => e.product.id == product.id && e.size == selectedSize,
      orElse: () => CartItem(
        product: product,
        size: selectedSize,
        quantity: 0,
      ),
    );

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

          /// ✅ SIZE SELECTOR
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
                : cartItem.quantity == 0
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () =>
                            cart.add(product, selectedSize),
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
                                cart.decrease(cartItem),
                          ),
                          Text(cartItem.quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add,
                                color: Colors.orange),
                            onPressed:
                                cartItem.quantity >= stock
                                    ? null
                                    : () => cart.increase(cartItem),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

/// ================= SIZE SELECTOR =================
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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.orange
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: stock == 0
                    ? Colors.grey
                    : isSelected
                        ? Colors.orange
                        : Colors.grey.shade300,
              ),
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
                decoration:
                    stock == 0 ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
