import 'package:flutter/material.dart';

import '../../../../routes/app_router.dart';
import '../../../models/product_model.dart';
import '../../../repositories/product_repository.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/review_controller.dart';
import '../controllers/wishlist_controller.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductRepository _productRepo = ProductRepository();
  final WishlistController _wishlistController = WishlistController();
  final CartController _cartController = CartController();
  final ReviewController _reviewController = ReviewController();

  late Product product;
  bool isFavorite = false;
  bool isRefreshing = false;
  bool isSubmitting = false;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    loadWishlistStatus();
    refreshProduct();
  }

  Future<void> refreshProduct() async {
    setState(() => isRefreshing = true);
    try {
      final updated = await _productRepo.getProductById(product.id);
      if (updated != null) {
        setState(() => product = updated);
      }
    } finally {
      setState(() => isRefreshing = false);
    }
  }

  Future<void> loadWishlistStatus() async {
    if (!_wishlistController.isLoggedIn) return;

    try {
      final ids = await _wishlistController.getWishlistIds();
      setState(() => isFavorite = ids.contains(product.id));
    } catch (_) {}
  }

  Future<void> toggleWishlist() async {
    if (!_wishlistController.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to use wishlist')),
      );
      return;
    }

    final wasFavorite = isFavorite;
    setState(() => isFavorite = !isFavorite);

    try {
      if (wasFavorite) {
        await _wishlistController.removeFromWishlist(product.id);
      } else {
        await _wishlistController.addToWishlist(product.id);
      }
    } catch (_) {
      setState(() => isFavorite = wasFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wishlist update failed')),
      );
    }
  }

  void showRatingSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rating Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Average rating: ${product.ratingAvg}'),
            const SizedBox(height: 6),
            Text('Total ratings: ${product.ratingCount}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void showRateDialog() {
    if (!_reviewController.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to rate products')),
      );
      return;
    }

    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: const Text('Rate Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return IconButton(
                    onPressed: () => setLocalState(() {
                      selectedRating = star;
                    }),
                    icon: Icon(
                      star <= selectedRating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setState(() => isSubmitting = true);
                      try {
                        await _reviewController.submitReview(
                          productId: product.id,
                          rating: selectedRating,
                          comment: commentController.text.trim(),
                        );
                        Navigator.pop(context);
                        await refreshProduct();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thanks for your rating'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      } finally {
                        setState(() => isSubmitting = false);
                      }
                    },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addToCart() async {
    if (!_cartController.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add to cart')),
      );
      return;
    }

    try {
      await _cartController.addToCart(product.id, quantity: quantity);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            onPressed: refreshProduct,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.cart);
            },
            icon: const Icon(Icons.shopping_cart),
          ),
          IconButton(
            onPressed: toggleWishlist,
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: isRefreshing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      product.image,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: showRatingSummary,
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${product.ratingAvg} (${product.ratingCount})',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () => setState(() => quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$quantity'),
                      IconButton(
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: addToCart,
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Add to Cart'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: showRateDialog,
                    child: const Text('Rate Product'),
                  ),
                ],
              ),
            ),
    );
  }
}
