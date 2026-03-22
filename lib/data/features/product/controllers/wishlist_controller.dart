import '../../../models/product_model.dart';
import '../../../repositories/product_repository.dart';
import '../../../repositories/wishlist_repository.dart';

class WishlistController {
  final WishlistRepository _repo = WishlistRepository();
  final ProductRepository _productRepo = ProductRepository();

  bool get isLoggedIn => _repo.currentUserId != null;

  Future<List<String>> getWishlistIds() async {
    return _repo.getWishlistIds();
  }

  Future<void> addToWishlist(String productId) async {
    await _repo.addToWishlist(productId);
  }

  Future<void> removeFromWishlist(String productId) async {
    await _repo.removeFromWishlist(productId);
  }

  Future<List<Product>> getWishlistProducts() async {
    final ids = await _repo.getWishlistIds();
    if (ids.isEmpty) return [];

    final products = await Future.wait(
      ids.map((id) => _productRepo.getProductById(id)),
    );

    return products.whereType<Product>().toList();
  }
}
