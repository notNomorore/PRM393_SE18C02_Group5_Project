import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item_model.dart';

class CartRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _cartCollection(String uid) {
    return _db.collection('users').doc(uid).collection('cart');
  }

  Future<List<CartItem>> getCartItems() async {
    final uid = currentUserId;
    if (uid == null) return [];

    final snapshot = await _cartCollection(uid).get();
    return snapshot.docs
        .map((doc) => CartItem.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    final docRef = _cartCollection(uid).doc(productId);
    await _db.runTransaction((tx) async {
      final doc = await tx.get(docRef);
      final currentQty = doc.exists ? (doc.data()?['quantity'] ?? 0) : 0;
      final newQty = currentQty + quantity;

      if (newQty <= 0) {
        tx.delete(docRef);
      } else {
        tx.set(docRef, {
          'productId': productId,
          'quantity': newQty,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    final docRef = _cartCollection(uid).doc(productId);
    if (quantity <= 0) {
      await docRef.delete();
      return;
    }

    await docRef.set({
      'productId': productId,
      'quantity': quantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromCart(String productId) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    await _cartCollection(uid).doc(productId).delete();
  }

  Future<void> clearCart() async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    final snapshot = await _cartCollection(uid).get();
    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
