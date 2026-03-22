import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_user_model.dart';

class AdminUserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<AdminUser>> getUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs
        .map((doc) => AdminUser.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> setUserBanned(String uid, bool isBanned) async {
    await _db.collection('users').doc(uid).update({
      'isBanned': isBanned,
    });
  }
}
