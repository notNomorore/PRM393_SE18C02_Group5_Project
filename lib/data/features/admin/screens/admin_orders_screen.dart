import 'package:flutter/material.dart';

import '../../../models/order_model.dart';
import '../../../repositories/admin_order_repository.dart';
import '../widgets/admin_guard.dart';
import '../../../../routes/app_router.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final AdminOrderRepository _repo = AdminOrderRepository();

  List<OrderModel> orders = [];
  bool isLoading = true;
  String statusFilter = 'all';
  String userIdFilter = '';
  bool cancelledOnly = false;

  final userIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  @override
  void dispose() {
    userIdController.dispose();
    super.dispose();
  }

  Future<void> loadOrders() async {
    setState(() => isLoading = true);
    try {
      final data = await _repo.getOrders(
        status: statusFilter,
        userId: userIdFilter,
        cancelledOnly: cancelledOnly,
      );
      setState(() => orders = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void applyFilters() {
    userIdFilter = userIdController.text.trim();
    loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          actions: [
            IconButton(
              onPressed: loadOrders,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: userIdController,
                    decoration: const InputDecoration(
                      labelText: 'Filter by userId',
                    ),
                    onSubmitted: (_) => applyFilters(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: statusFilter,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All'),
                            ),
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
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => statusFilter = value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SwitchListTile(
                          value: cancelledOnly,
                          title: const Text('Cancelled only'),
                          onChanged: (value) {
                            setState(() => cancelledOnly = value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: applyFilters,
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orders.isEmpty
                      ? const Center(child: Text('No orders'))
                      : ListView.separated(
                          itemCount: orders.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return ListTile(
                              title: Text('Order #${order.id}'),
                              subtitle: Text(
                                'User: ${order.userId}\nStatus: ${order.status} • Total: \$${order.total.toStringAsFixed(2)}',
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.adminOrderDetail,
                                  arguments: {
                                    'userId': order.userId,
                                    'orderId': order.id,
                                  },
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
