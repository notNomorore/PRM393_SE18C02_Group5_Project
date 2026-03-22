import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final String status;
  final String couponCode;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.status,
    required this.couponCode,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    final itemsData = (data['items'] ?? []) as List<dynamic>;
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '',
      items: itemsData
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      couponCode: data['couponCode'] ?? '',
      createdAt: data['createdAt'] == null
          ? DateTime.now()
          : (data['createdAt'] as dynamic).toDate(),
    );
  }
}
