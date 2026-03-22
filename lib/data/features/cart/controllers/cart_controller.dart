import '../../../models/cart_item_model.dart';
import '../../../models/product_model.dart';
import '../../../repositories/cart_repository.dart';
import '../../../repositories/product_repository.dart';

class CartItemView {
  final Product product;
  final int quantity;

  CartItemView({
    required this.product,
    required this.quantity,
  });
}

class CartController {
  final CartRepository _repo = CartRepository();
  final ProductRepository _productRepo = ProductRepository();

  bool get isLoggedIn => _repo.currentUserId != null;

  Future<List<CartItemView>> getCartItems() async {
    final items = await _repo.getCartItems();
    if (items.isEmpty) return [];

    final products = await Future.wait(
      items.map((item) => _productRepo.getProductById(item.productId)),
    );

    final result = <CartItemView>[];
    for (var i = 0; i < items.length; i++) {
      final product = products[i];
      if (product != null) {
        result.add(CartItemView(product: product, quantity: items[i].quantity));
      }
    }

    return result;
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    await _repo.addToCart(productId, quantity: quantity);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    await _repo.updateQuantity(productId, quantity);
  }

  Future<void> removeFromCart(String productId) async {
    await _repo.removeFromCart(productId);
  }

  Future<void> clearCart() async {
    await _repo.clearCart();
  }
}
