import 'package:flutter/material.dart';

import '../../../../routes/app_router.dart';
import '../../../models/order_model.dart';
import '../controllers/order_controller.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderController _controller = OrderController();

  OrderModel? order;
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    loadOrder();
  }

  Future<void> loadOrder() async {
    setState(() => isLoading = true);
    try {
      final data = await _controller.getOrderById(widget.orderId);
      setState(() => order = data);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load order')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool get canCancel {
    final status = order?.status ?? '';
    return status == 'pending' || status == 'processing';
  }

  Future<void> cancelOrder() async {
    if (order == null) return;
    setState(() => isUpdating = true);
    try {
      await _controller.cancelOrder(order!.id);
      await loadOrder();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to cancel order')),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  Future<void> reorder() async {
    if (order == null) return;
    setState(() => isUpdating = true);
    try {
      await _controller.reorder(order!.items);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Items added to cart')),
      );
      Navigator.pushNamed(context, AppRouter.cart);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reorder')),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Detail'),
        actions: [
          IconButton(
            onPressed: loadOrder,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('Order not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${order!.id}'),
                      const SizedBox(height: 6),
                      Text('Status: ${order!.status}'),
                      const Divider(height: 24),
                      ...order!.items.map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.name),
                          subtitle: Text('\$${item.price} x ${item.quantity}'),
                          trailing: Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Text('Subtotal'),
                          const Spacer(),
                          Text('\$${order!.subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('Discount'),
                          const Spacer(),
                          Text('-\$${order!.discount.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text('Total'),
                          const Spacer(),
                          Text(
                            '\$${order!.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (order!.couponCode.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('Coupon: ${order!.couponCode}'),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isUpdating ? null : reorder,
                              child: const Text('Reorder'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isUpdating || !canCancel
                                  ? null
                                  : cancelOrder,
                              child: const Text('Cancel Order'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
