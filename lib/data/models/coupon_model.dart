class Coupon {
  final String code;
  final String title;
  final String description;
  final String discountType; // percent or fixed
  final double discountValue;
  final double minSubtotal;
  final bool isActive;
  final int usageCount;
  final double totalDiscount;

  Coupon({
    required this.code,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minSubtotal,
    required this.isActive,
    required this.usageCount,
    required this.totalDiscount,
  });

  factory Coupon.fromFirestore(Map<String, dynamic> data, String id) {
    return Coupon(
      code: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      discountType: data['discountType'] ?? 'percent',
      discountValue: (data['discountValue'] ?? 0).toDouble(),
      minSubtotal: (data['minSubtotal'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? false,
      usageCount: ((data['usageCount'] ?? 0) as num).toInt(),
      totalDiscount: (data['totalDiscount'] ?? 0).toDouble(),
    );
  }
}
