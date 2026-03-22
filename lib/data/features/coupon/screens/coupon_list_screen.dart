import 'package:flutter/material.dart';

import '../../../models/coupon_model.dart';
import '../controllers/coupon_controller.dart';

class CouponListScreen extends StatefulWidget {
  const CouponListScreen({super.key});

  @override
  State<CouponListScreen> createState() => _CouponListScreenState();
}

class _CouponListScreenState extends State<CouponListScreen> {
  final CouponController _controller = CouponController();

  List<Coupon> coupons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    setState(() => isLoading = true);
    try {
      final data = await _controller.getAvailableCoupons();
      setState(() => coupons = data);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load coupons')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Coupons')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : coupons.isEmpty
              ? const Center(child: Text('No coupons available'))
              : ListView.separated(
                  itemCount: coupons.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final c = coupons[index];
                    final condition =
                        'Min subtotal: \$${c.minSubtotal.toStringAsFixed(2)}';
                    return ListTile(
                      title: Text('${c.title} (${c.code})'),
                      subtitle: Text('${c.description}\n$condition'),
                      isThreeLine: true,
                      trailing: Text(
                        c.discountType == 'fixed'
                            ? '-\$${c.discountValue}'
                            : '-${c.discountValue}%',
                      ),
                    );
                  },
                ),
    );
  }
}
