// data/repositories/auth_repository.dart

import '../../core/services/firebase_service.dart';

class AuthRepository {
  final FirebaseService _firebase = FirebaseService();

  Future<void> register(String email, String password) async {
    final userCredential = await _firebase.auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firebase.db.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
      'role': 'user',
    });
  }

  Future<void> login(String email, String password) async {
    await _firebase.auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _firebase.auth.signOut();
  }
}