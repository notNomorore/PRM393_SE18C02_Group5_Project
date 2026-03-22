class Review {
  final String id;
  final String userId;
  final String productId;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromFirestore(Map<String, dynamic> data, String id) {
    return Review(
      id: id,
      userId: data['userId'],
      productId: data['productId'],
      rating: data['rating'],
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'].toDate(),
    );
  }
}