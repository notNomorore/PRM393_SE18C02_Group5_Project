import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> getProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return {};

    final doc = await _db.collection('users').doc(uid).get();
    return doc.data() ?? {};
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    await _db.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'address': address,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final providers = user.providerData.map((e) => e.providerId).toList();
    if (!providers.contains('password')) {
      throw Exception('Please reset password via email for this account');
    }

    final email = user.email;
    if (email == null) {
      throw Exception('Missing email');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
