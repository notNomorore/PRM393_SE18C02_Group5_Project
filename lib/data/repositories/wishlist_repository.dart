import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _wishlistCollection(String uid) {
    return _db.collection('users').doc(uid).collection('wishlist');
  }

  Future<List<String>> getWishlistIds() async {
    final uid = currentUserId;
    if (uid == null) return [];

    final snapshot = await _wishlistCollection(uid).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> addToWishlist(String productId) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    await _wishlistCollection(uid).doc(productId).set({
      'productId': productId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromWishlist(String productId) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    await _wishlistCollection(uid).doc(productId).delete();
  }
}
