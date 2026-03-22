import 'package:flutter/material.dart';

import '../../../models/order_model.dart';
import '../../../repositories/admin_order_repository.dart';
import '../widgets/admin_guard.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final String userId;
  final String orderId;

  const AdminOrderDetailScreen({
    super.key,
    required this.userId,
    required this.orderId,
  });

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final AdminOrderRepository _repo = AdminOrderRepository();

  OrderModel? order;
  Map<String, dynamic> userInfo = {};
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
      final data = await _repo.getOrderByUser(widget.userId, widget.orderId);
      final info = await _repo.getUserInfo(widget.userId);
      setState(() {
        order = data;
        userInfo = info;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateStatus(String status) async {
    if (order == null) return;
    setState(() => isUpdating = true);
    try {
      await _repo.updateOrderStatus(
        userId: widget.userId,
        orderId: widget.orderId,
        status: status,
      );
      await loadOrder();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    } finally {
      setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
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
                        Text('Buyer: ${userInfo['email'] ?? widget.userId}'),
                        if ((userInfo['name'] ?? '').toString().isNotEmpty)
                          Text('Name: ${userInfo['name']}'),
                        if ((userInfo['phone'] ?? '').toString().isNotEmpty)
                          Text('Phone: ${userInfo['phone']}'),
                        if ((userInfo['address'] ?? '').toString().isNotEmpty)
                          Text('Address: ${userInfo['address']}'),
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
                        DropdownButtonFormField<String>(
                          value: order!.status,
                          decoration: const InputDecoration(
                            labelText: 'Update Status',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'processing',
                              child: Text('Processing'),
                            ),
                            DropdownMenuItem(
                              value: 'shipped',
                              child: Text('Shipped'),
                            ),
                            DropdownMenuItem(
                              value: 'completed',
                              child: Text('Completed'),
                            ),
                            DropdownMenuItem(
                              value: 'cancelled',
                              child: Text('Cancelled'),
                            ),
                          ],
                          onChanged: isUpdating
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  updateStatus(value);
                                },
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
