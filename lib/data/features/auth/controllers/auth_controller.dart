import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= VALIDATION =================

  void validateRegister(
      String email, String password, String confirmPassword) {
    if (email.isEmpty || !email.contains("@")) {
      throw "Invalid email";
    }

    if (password.length < 6) {
      throw "Password must be at least 6 characters";
    }

    if (password != confirmPassword) {
      throw "Passwords do not match";
    }
  }

  void validateLogin(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      throw "Please fill all fields";
    }
  }

  // ================= REGISTER =================

  Future<void> register(
      String email, String password, String confirmPassword) async {
    try {
      // 1. validate input
      validateRegister(email, password, confirmPassword);

      // 2. tạo account
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // 3. lưu user vào Firestore
      await _db.collection("users").doc(uid).set({
        "email": email,
        "role": "user",
        "createdAt": FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw "Email already used";
      } else if (e.code == 'invalid-email') {
        throw "Invalid email";
      } else if (e.code == 'weak-password') {
        throw "Weak password";
      } else {
        throw e.message ?? "Register failed";
      }
    }
  }

  // ================= LOGIN =================

  Future<void> _ensureNotBanned(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    if (data['isBanned'] == true) {
      await _auth.signOut();
      throw "Account is banned";
    }
  }

  Future<void> login(String email, String password) async {
    try {
      validateLogin(email, password);

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _ensureNotBanned(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw "User not found";
      } else if (e.code == 'wrong-password') {
        throw "Wrong password";
      } else if (e.code == 'invalid-email') {
        throw "Invalid email";
      } else {
        throw e.message ?? "Login failed";
      }
    }
  }

  // ================= FORGOT PASSWORD =================

  Future<void> forgotPassword(String email) async {
    if (email.isEmpty || !email.contains("@")) {
      throw "Invalid email";
    }

    await _auth.sendPasswordResetEmail(email: email);
  }

  // ================= LOGOUT =================

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ================= CURRENT USER =================

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ================= GOOGLE LOGIN =================

  Future<void> loginWithGoogle() async {
    try {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      await _auth.signInWithPopup(authProvider);

      // 👉 nếu login lần đầu → lưu user vào Firestore
      final user = _auth.currentUser;

      if (user != null) {
        final doc = await _db.collection("users").doc(user.uid).get();

        if (!doc.exists) {
          await _db.collection("users").doc(user.uid).set({
            "email": user.email,
            "role": "user",
            "createdAt": FieldValue.serverTimestamp(),
          });
        }

        await _ensureNotBanned(user.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Google login failed";
    }
  }
}