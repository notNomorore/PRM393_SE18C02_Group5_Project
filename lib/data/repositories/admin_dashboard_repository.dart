import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_dashboard_model.dart';

class AdminDashboardRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AdminDashboardStats> getStats() async {
    final usersSnap = await _db.collection('users').get();
    final ordersSnap = await _db.collectionGroup('orders').get();
    final productsSnap = await _db.collection('products').get();
    final couponsSnap = await _db.collection('coupons').get();

    return AdminDashboardStats(
      users: usersSnap.size,
      orders: ordersSnap.size,
      products: productsSnap.size,
      coupons: couponsSnap.size,
    );
  }
}
