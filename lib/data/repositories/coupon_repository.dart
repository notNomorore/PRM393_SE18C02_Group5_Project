import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/coupon_model.dart';

class CouponRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Coupon>> getAvailableCoupons() async {
    final snapshot = await _db
        .collection('coupons')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Coupon.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<Coupon?> getCouponByCode(String code) async {
    final doc = await _db.collection('coupons').doc(code).get();
    if (!doc.exists || doc.data() == null) return null;

    return Coupon.fromFirestore(doc.data()!, doc.id);
  }

  Future<List<Coupon>> getAllCoupons() async {
    final snapshot = await _db.collection('coupons').get();

    return snapshot.docs
        .map((doc) => Coupon.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> createCoupon(Coupon coupon) async {
    await _db.collection('coupons').doc(coupon.code).set({
      'title': coupon.title,
      'description': coupon.description,
      'discountType': coupon.discountType,
      'discountValue': coupon.discountValue,
      'minSubtotal': coupon.minSubtotal,
      'isActive': coupon.isActive,
      'usageCount': coupon.usageCount,
      'totalDiscount': coupon.totalDiscount,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCoupon(Coupon coupon) async {
    await _db.collection('coupons').doc(coupon.code).update({
      'title': coupon.title,
      'description': coupon.description,
      'discountType': coupon.discountType,
      'discountValue': coupon.discountValue,
      'minSubtotal': coupon.minSubtotal,
      'isActive': coupon.isActive,
    });
  }

  Future<void> deleteCoupon(String code) async {
    await _db.collection('coupons').doc(code).delete();
  }

  Future<void> incrementUsage(String code, double discountValue) async {
    final docRef = _db.collection('coupons').doc(code);
    await _db.runTransaction((tx) async {
      final doc = await tx.get(docRef);
      if (!doc.exists) return;

      final data = doc.data() ?? {};
      final usageCount = ((data['usageCount'] ?? 0) as num).toInt();
      final totalDiscount = (data['totalDiscount'] ?? 0).toDouble();

      tx.update(docRef, {
        'usageCount': usageCount + 1,
        'totalDiscount': totalDiscount + discountValue,
        'lastUsedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
