import '../../../repositories/review_repository.dart';

class ReviewController {
  final ReviewRepository _repo = ReviewRepository();

  bool get isLoggedIn => _repo.currentUserId != null;

  Future<void> submitReview({
    required String productId,
    required int rating,
    String comment = '',
  }) async {
    await _repo.submitReview(
      productId: productId,
      rating: rating,
      comment: comment,
    );
  }
}
