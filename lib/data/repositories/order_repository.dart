import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/order_item_model.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _orderCollection(String uid) {
    return _db.collection('users').doc(uid).collection('orders');
  }

  Future<String> createOrder({
    required List<OrderItem> items,
    required double subtotal,
    required double discount,
    required double total,
    required String couponCode,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    final docRef = _orderCollection(uid).doc();
    await docRef.set({
      'userId': uid,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'couponCode': couponCode,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Future<List<OrderModel>> getOrders() async {
    final uid = currentUserId;
    if (uid == null) return [];

    final snapshot = await _orderCollection(uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
      .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
      .toList();
  }

    Future<OrderModel?> getOrderById(String orderId) async {
    final uid = currentUserId;
    if (uid == null) return null;

    final doc = await _orderCollection(uid).doc(orderId).get();
    if (!doc.exists || doc.data() == null) return null;

    return OrderModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    await _orderCollection(uid).doc(orderId).update({
      'status': status,
    });
  }
}
