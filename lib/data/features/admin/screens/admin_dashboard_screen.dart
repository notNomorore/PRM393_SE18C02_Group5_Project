import 'package:flutter/material.dart';

import '../../../models/admin_dashboard_model.dart';
import '../../../repositories/admin_dashboard_repository.dart';
import '../widgets/admin_guard.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminDashboardRepository _repo = AdminDashboardRepository();

  AdminDashboardStats? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    setState(() => isLoading = true);
    try {
      final data = await _repo.getStats();
      setState(() => stats = data);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load stats')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget statCard(String label, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              onPressed: loadStats,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : stats == null
                ? const Center(child: Text('No data'))
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      statCard(
                        'Users',
                        stats!.users.toString(),
                        Icons.people,
                      ),
                      statCard(
                        'Orders',
                        stats!.orders.toString(),
                        Icons.receipt_long,
                      ),
                      statCard(
                        'Products',
                        stats!.products.toString(),
                        Icons.inventory_2,
                      ),
                      statCard(
                        'Coupons',
                        stats!.coupons.toString(),
                        Icons.local_offer,
                      ),
                    ],
                  ),
      ),
    );
  }
}
