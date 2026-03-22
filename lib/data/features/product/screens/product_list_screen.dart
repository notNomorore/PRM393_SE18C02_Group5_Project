import 'package:flutter/material.dart';

import '../../../../routes/app_router.dart';
import '../../../../core/services/admin_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../models/product_model.dart';
import '../controllers/product_controller.dart';
import '../controllers/wishlist_controller.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductController _controller = ProductController();
  final WishlistController _wishlistController = WishlistController();
  final AdminService _adminService = AdminService();
  final AuthController _authController = AuthController();

  List<Product> products = [];
  List<Product> filtered = [];
  Set<String> wishlistIds = {};

  final searchController = TextEditingController();
  String selectedCategory = 'All';
  RangeValues priceRange = const RangeValues(0, 10000);
  RangeValues priceBounds = const RangeValues(0, 10000);
  String sortKey = 'name_asc';

  bool isLoading = true;
  late Future<bool> isAdminFuture;

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadWishlist();
    isAdminFuture = _adminService.isAdmin();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadProducts() async {
    try {
      final data = await _controller.getProducts();

      setState(() {
        products = data;
        filtered = data;
        priceBounds = _derivePriceRange(data);
        priceRange = priceBounds;
      });

      applyFilters();
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load products")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  RangeValues _derivePriceRange(List<Product> data) {
    if (data.isEmpty) return const RangeValues(0, 10000);
    final prices = data.map((p) => p.price).toList();
    prices.sort();
    return RangeValues(prices.first, prices.last);
  }

  List<String> get categories {
    final set = <String>{'All'};
    for (final p in products) {
      if (p.category.isNotEmpty) set.add(p.category);
    }
    return set.toList();
  }

  void applyFilters() {
    final keyword = searchController.text.trim().toLowerCase();
    final minPrice = priceRange.start;
    final maxPrice = priceRange.end;

    List<Product> result = products.where((p) {
      final matchesKeyword = keyword.isEmpty ||
          p.name.toLowerCase().contains(keyword);
      final matchesCategory =
          selectedCategory == 'All' || p.category == selectedCategory;
      final matchesPrice = p.price >= minPrice && p.price <= maxPrice;

      return matchesKeyword && matchesCategory && matchesPrice;
    }).toList();

    result.sort((a, b) {
      switch (sortKey) {
        case 'price_asc':
          return a.price.compareTo(b.price);
        case 'price_desc':
          return b.price.compareTo(a.price);
        case 'rating_desc':
          return b.ratingAvg.compareTo(a.ratingAvg);
        case 'name_desc':
          return b.name.compareTo(a.name);
        default:
          return a.name.compareTo(b.name);
      }
    });

    setState(() => filtered = result);
  }

  Future<void> showFilterSheet() async {
    final tempCategory = selectedCategory;
    final tempRange = priceRange;
    final bounds = priceBounds;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        String localCategory = tempCategory;
        RangeValues localRange = tempRange;

        return StatefulBuilder(
          builder: (context, setLocalState) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: localCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setLocalState(() => localCategory = value);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Price range: \$${localRange.start.toStringAsFixed(0)} - \$${localRange.end.toStringAsFixed(0)}',
                ),
                RangeSlider(
                  values: localRange,
                  min: bounds.start,
                  max: bounds.end,
                  onChanged: (value) {
                    setLocalState(() => localRange = value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = 'All';
                            priceRange = priceBounds;
                          });
                          applyFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = localCategory;
                            priceRange = localRange;
                          });
                          applyFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> loadWishlist() async {
    if (!_wishlistController.isLoggedIn) return;

    try {
      final ids = await _wishlistController.getWishlistIds();
      setState(() => wishlistIds = ids.toSet());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load wishlist")),
      );
    }
  }

  Future<void> toggleWishlist(Product p) async {
    if (!_wishlistController.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to use wishlist")),
      );
      return;
    }

    final isInWishlist = wishlistIds.contains(p.id);
    setState(() {
      if (isInWishlist) {
        wishlistIds.remove(p.id);
      } else {
        wishlistIds.add(p.id);
      }
    });

    try {
      if (isInWishlist) {
        await _wishlistController.removeFromWishlist(p.id);
      } else {
        await _wishlistController.addToWishlist(p.id);
      }
    } catch (e) {
      setState(() {
        if (isInWishlist) {
          wishlistIds.add(p.id);
        } else {
          wishlistIds.remove(p.id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wishlist update failed")),
      );
    }
  }

  void showRatingSummary(Product p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rating Summary"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Average rating: ${p.ratingAvg}"),
            const SizedBox(height: 6),
            Text("Total ratings: ${p.ratingCount}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget buildProduct(Product p) {
    final isFavorite = wishlistIds.contains(p.id);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼 IMAGE
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  p.image,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: IconButton(
                  onPressed: () => toggleWishlist(p),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: isFavorite ? Colors.redAccent : Colors.white70,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "\$${p.price}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // ⭐ RATING
                InkWell(
                  onTap: () => showRatingSummary(p),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${p.ratingAvg} (${p.ratingCount})",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tech Store"),
        actions: [
          IconButton(
            onPressed: () async {
              await _authController.logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.login,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.profile);
            },
            icon: const Icon(Icons.person),
          ),
          FutureBuilder<bool>(
            future: isAdminFuture,
            builder: (context, snapshot) {
              if (snapshot.data != true) return const SizedBox.shrink();
              return IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.admin);
                },
                icon: const Icon(Icons.admin_panel_settings),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.orders);
            },
            icon: const Icon(Icons.receipt_long),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.cart);
            },
            icon: const Icon(Icons.shopping_cart),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.wishlist);
            },
            icon: const Icon(Icons.favorite),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search products',
                          ),
                          onChanged: (_) => applyFilters(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: showFilterSheet,
                        icon: const Icon(Icons.filter_list),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() => sortKey = value);
                          applyFilters();
                        },
                        icon: const Icon(Icons.sort),
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'name_asc',
                            child: Text('Name A-Z'),
                          ),
                          PopupMenuItem(
                            value: 'name_desc',
                            child: Text('Name Z-A'),
                          ),
                          PopupMenuItem(
                            value: 'price_asc',
                            child: Text('Price Low-High'),
                          ),
                          PopupMenuItem(
                            value: 'price_desc',
                            child: Text('Price High-Low'),
                          ),
                          PopupMenuItem(
                            value: 'rating_desc',
                            child: Text('Top Rated'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: GridView.builder(
                      itemCount: filtered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.productDetail,
                              arguments: p,
                            );
                          },
                          child: buildProduct(p),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}