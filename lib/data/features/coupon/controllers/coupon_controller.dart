import '../../../models/coupon_model.dart';
import '../../../repositories/coupon_repository.dart';

class CouponController {
  final CouponRepository _repo = CouponRepository();

  Future<List<Coupon>> getAvailableCoupons() async {
    return await _repo.getAvailableCoupons();
  }

  Future<Coupon?> getCouponByCode(String code) async {
    if (code.trim().isEmpty) return null;
    return await _repo.getCouponByCode(code.trim());
  }

  Future<List<Coupon>> getAllCoupons() async {
    return await _repo.getAllCoupons();
  }

  Future<void> createCoupon(Coupon coupon) async {
    await _repo.createCoupon(coupon);
  }

  Future<void> updateCoupon(Coupon coupon) async {
    await _repo.updateCoupon(coupon);
  }

  Future<void> deleteCoupon(String code) async {
    await _repo.deleteCoupon(code);
  }

  Future<void> incrementUsage(String code, double discountValue) async {
    await _repo.incrementUsage(code, discountValue);
  }
}
