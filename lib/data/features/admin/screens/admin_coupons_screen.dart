import 'package:flutter/material.dart';

import '../../../models/coupon_model.dart';
import '../../coupon/controllers/coupon_controller.dart';
import '../widgets/admin_guard.dart';

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
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
      final data = await _controller.getAllCoupons();
      setState(() => coupons = data);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load coupons')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> showCouponForm({Coupon? coupon}) async {
    final codeController = TextEditingController(text: coupon?.code ?? '');
    final titleController = TextEditingController(text: coupon?.title ?? '');
    final descController =
        TextEditingController(text: coupon?.description ?? '');
    final discountValueController = TextEditingController(
      text: coupon == null ? '' : coupon.discountValue.toString(),
    );
    final minSubtotalController = TextEditingController(
      text: coupon == null ? '' : coupon.minSubtotal.toString(),
    );

    String discountType = coupon?.discountType ?? 'percent';
    bool isActive = coupon?.isActive ?? true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(coupon == null ? 'Create Coupon' : 'Edit Coupon'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: codeController,
                enabled: coupon == null,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              DropdownButtonFormField<String>(
                value: discountType,
                decoration: const InputDecoration(labelText: 'Discount Type'),
                items: const [
                  DropdownMenuItem(
                    value: 'percent',
                    child: Text('Percent'),
                  ),
                  DropdownMenuItem(
                    value: 'fixed',
                    child: Text('Fixed'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) discountType = value;
                },
              ),
              TextField(
                controller: discountValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Discount Value'),
              ),
              TextField(
                controller: minSubtotalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Min Subtotal'),
              ),
              SwitchListTile(
                title: const Text('Active'),
                value: isActive,
                onChanged: (value) {
                  isActive = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final code = codeController.text.trim();
    if (code.isEmpty) return;

    final discountValue = double.tryParse(discountValueController.text) ?? 0;
    final minSubtotal = double.tryParse(minSubtotalController.text) ?? 0;

    final newCoupon = Coupon(
      code: code,
      title: titleController.text.trim(),
      description: descController.text.trim(),
      discountType: discountType,
      discountValue: discountValue,
      minSubtotal: minSubtotal,
      isActive: isActive,
      usageCount: coupon?.usageCount ?? 0,
      totalDiscount: coupon?.totalDiscount ?? 0,
    );

    try {
      if (coupon == null) {
        await _controller.createCoupon(newCoupon);
      } else {
        await _controller.updateCoupon(newCoupon);
      }
      await loadCoupons();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save coupon')),
      );
    }
  }

  Future<void> deleteCoupon(String code) async {
    try {
      await _controller.deleteCoupon(code);
      await loadCoupons();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete coupon')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Coupons'),
          actions: [
            IconButton(
              onPressed: loadCoupons,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showCouponForm(),
          child: const Icon(Icons.add),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : coupons.isEmpty
                ? const Center(child: Text('No coupons'))
                : ListView.separated(
                    itemCount: coupons.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final c = coupons[index];
                      final usageInfo =
                          'Used: ${c.usageCount}  •  Discount: \$${c.totalDiscount.toStringAsFixed(2)}';
                      return ListTile(
                        title: Text('${c.title} (${c.code})'),
                        subtitle: Text('${c.description}\n$usageInfo'),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              onPressed: () => showCouponForm(coupon: c),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => deleteCoupon(c.code),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
