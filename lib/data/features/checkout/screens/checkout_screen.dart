import 'package:flutter/material.dart';

import '../../../../routes/app_router.dart';
import '../../../models/order_item_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../coupon/controllers/coupon_controller.dart';
import '../../order/controllers/order_controller.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartController _cartController = CartController();
  final CouponController _couponController = CouponController();
  final OrderController _orderController = OrderController();

  final couponController = TextEditingController();

  List<CartItemView> items = [];
  bool isLoading = true;
  bool isPlacing = false;

  double subtotal = 0;
  double discount = 0;
  String appliedCoupon = '';
  String discountNote = '';

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    if (!_cartController.isLoggedIn) {
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);
    try {
      final data = await _cartController.getCartItems();
      setState(() => items = data);
      recalcTotals();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load cart')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void recalcTotals() {
    double newSubtotal = 0;
    for (final item in items) {
      newSubtotal += item.product.price * item.quantity;
    }

    double newDiscount = discount;
    if (appliedCoupon.isEmpty) {
      newDiscount = 0;
    }

    if (newDiscount > newSubtotal) {
      newDiscount = newSubtotal;
    }

    setState(() {
      subtotal = newSubtotal;
      discount = newDiscount;
    });
  }

  double get total => subtotal - discount;

  Future<void> applyCoupon() async {
    final code = couponController.text.trim();
    if (code.isEmpty) return;

    try {
      final coupon = await _couponController.getCouponByCode(code);
      if (coupon == null || !coupon.isActive) {
        setState(() {
          appliedCoupon = '';
          discount = 0;
          discountNote = 'Invalid coupon code';
        });
        return;
      }

      if (subtotal < coupon.minSubtotal) {
        setState(() {
          appliedCoupon = '';
          discount = 0;
          discountNote =
              'Minimum subtotal required: \$${coupon.minSubtotal}';
        });
        return;
      }

      double newDiscount = 0;
      if (coupon.discountType == 'fixed') {
        newDiscount = coupon.discountValue;
      } else {
        newDiscount = subtotal * (coupon.discountValue / 100);
      }

      if (newDiscount > subtotal) {
        newDiscount = subtotal;
      }

      setState(() {
        appliedCoupon = coupon.code;
        discount = newDiscount;
        discountNote =
            'Applied ${coupon.discountType} discount: ${coupon.discountValue}';
      });
    } catch (_) {
      setState(() {
        appliedCoupon = '';
        discount = 0;
        discountNote = 'Failed to apply coupon';
      });
    }
  }

  Future<void> placeOrder() async {
    if (items.isEmpty) return;
    if (!_orderController.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place order')),
      );
      return;
    }

    setState(() => isPlacing = true);
    try {
      final orderItems = items
          .map(
            (item) => OrderItem(
              productId: item.product.id,
              name: item.product.name,
              image: item.product.image,
              price: item.product.price,
              quantity: item.quantity,
            ),
          )
          .toList();

      final orderId = await _orderController.placeOrder(
        orderItems: orderItems,
        subtotal: subtotal,
        discount: discount,
        total: total,
        couponCode: appliedCoupon,
      );

      if (appliedCoupon.isNotEmpty && discount > 0) {
        await _couponController.incrementUsage(appliedCoupon, discount);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully')),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRouter.orderDetail,
        arguments: orderId,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cartController.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please login to checkout'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.coupons);
            },
            icon: const Icon(Icons.local_offer),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      ...items.map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.product.name),
                          subtitle: Text(
                            '\$${item.product.price} x ${item.quantity}',
                          ),
                          trailing: Text(
                            '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                          ),
                        ),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: couponController,
                              decoration: const InputDecoration(
                                labelText: 'Coupon code',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: applyCoupon,
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                      if (discountNote.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            discountNote,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Subtotal'),
                          const Spacer(),
                          Text('\$${subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Discount'),
                          const Spacer(),
                          Text('-\$${discount.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Total'),
                          const Spacer(),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isPlacing ? null : placeOrder,
                          child: Text(
                            isPlacing ? 'Placing...' : 'Place Order',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
