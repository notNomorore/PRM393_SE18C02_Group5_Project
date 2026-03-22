import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> submitReview({
    required String productId,
    required int rating,
    String comment = '',
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('User not logged in');
    }
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }

    final productRef = _db.collection('products').doc(productId);
    final reviewRef = productRef.collection('reviews').doc(uid);

    await _db.runTransaction((tx) async {
      final productDoc = await tx.get(productRef);
      final reviewDoc = await tx.get(reviewRef);

      final data = productDoc.data() ?? {};
      final currentAvg = (data['ratingAvg'] ?? 0).toDouble();
      final currentCount = ((data['ratingCount'] ?? 0) as num).toInt();

      double newAvg = currentAvg;
      int newCount = currentCount;

      if (reviewDoc.exists) {
        final oldRating = (reviewDoc.data()?['rating'] ?? rating) as int;
        if (currentCount > 0) {
          newAvg =
              ((currentAvg * currentCount) - oldRating + rating) / currentCount;
        }
      } else {
        newCount = currentCount + 1;
        newAvg = ((currentAvg * currentCount) + rating) / newCount;
      }

      tx.set(reviewRef, {
        'userId': uid,
        'productId': productId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.update(productRef, {
        'ratingAvg': newAvg,
        'ratingCount': newCount,
      });
    });
  }
}
