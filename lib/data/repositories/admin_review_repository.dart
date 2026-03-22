import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review_model.dart';

class AdminReviewRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Review>> getRecentReviews() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _db
          .collectionGroup('reviews')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
    } on FirebaseException catch (e) {
      if (e.code != 'failed-precondition') rethrow;

      snapshot = await _db.collectionGroup('reviews').limit(100).get();
    }

    final reviews = snapshot.docs
        .map((doc) => Review.fromFirestore(doc.data(), doc.id))
        .toList();

    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }
}
