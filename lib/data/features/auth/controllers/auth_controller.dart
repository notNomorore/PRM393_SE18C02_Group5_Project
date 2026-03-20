import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw "User not found";
      } else if (e.code == 'wrong-password') {
        throw "Wrong password";
      } else {
        throw "Login failed";
      }
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw "Email already used";
      } else {
        throw "Register failed";
      }
    }
  }

  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> loginWithGoogle() async {
    try {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      await _auth.signInWithPopup(authProvider);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Google login failed";
    }
  }
}