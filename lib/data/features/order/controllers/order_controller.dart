import '../../../models/order_item_model.dart';
import '../../../models/order_model.dart';
import '../../../repositories/cart_repository.dart';
import '../../../repositories/order_repository.dart';

class OrderController {
  final OrderRepository _repo = OrderRepository();
  final CartRepository _cartRepo = CartRepository();

  bool get isLoggedIn => _repo.currentUserId != null;

  Future<String> placeOrder({
    required List<OrderItem> orderItems,
    required double subtotal,
    required double discount,
    required double total,
    required String couponCode,
  }) async {
    final orderId = await _repo.createOrder(
      items: orderItems,
      subtotal: subtotal,
      discount: discount,
      total: total,
      couponCode: couponCode,
    );

    await _cartRepo.clearCart();
    return orderId;
  }

  Future<List<OrderModel>> getOrders() async {
    return await _repo.getOrders();
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    return await _repo.getOrderById(orderId);
  }

  Future<void> cancelOrder(String orderId) async {
    await _repo.updateOrderStatus(orderId, 'cancelled');
  }

  Future<void> reorder(List<OrderItem> items) async {
    for (final item in items) {
      await _cartRepo.addToCart(item.productId, quantity: item.quantity);
    }
  }
}
