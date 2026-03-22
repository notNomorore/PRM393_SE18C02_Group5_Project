import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class AdminOrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<OrderModel>> getOrders({
    String? status,
    String? userId,
    bool cancelledOnly = false,
  }) async {
    Query<Map<String, dynamic>> query = _db.collectionGroup('orders');

    if (cancelledOnly) {
      query = query.where('status', isEqualTo: 'cancelled');
    } else if (status != null && status.isNotEmpty && status != 'all') {
      query = query.where('status', isEqualTo: status);
    }

    if (userId != null && userId.trim().isNotEmpty) {
      query = query.where('userId', isEqualTo: userId.trim());
    }

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await query.orderBy('createdAt', descending: true).get();
    } on FirebaseException catch (e) {
      if (e.code != 'failed-precondition') rethrow;
      snapshot = await query.get();
    }

    final orders = snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
        .toList();

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  Future<OrderModel?> getOrderByUser(String userId, String orderId) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return OrderModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data() ?? {};
  }

  Future<void> updateOrderStatus({
    required String userId,
    required String orderId,
    required String status,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
