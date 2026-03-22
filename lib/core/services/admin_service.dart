import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<bool> isAdmin() async {
    final uid = currentUserId;
    if (uid == null) return false;

    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    return data['role'] == 'admin' && (data['isBanned'] != true);
  }

  Future<bool> isBanned() async {
    final uid = currentUserId;
    if (uid == null) return false;

    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    return data['isBanned'] == true;
  }
}
