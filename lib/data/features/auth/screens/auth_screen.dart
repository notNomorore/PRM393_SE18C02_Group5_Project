import 'dart:ui';
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthController _auth = AuthController();

  bool isLogin = true;
  bool isLoading = false;

  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  void toggle() => setState(() => isLogin = !isLogin);

  void show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> handleLogin() async {
    setState(() => isLoading = true);
    try {
      await _auth.login(email.text.trim(), password.text.trim());
    } catch (e) {
      show(e.toString());
    }
    setState(() => isLoading = false);
  }

  Future<void> handleRegister() async {
    if (password.text != confirm.text) {
      show("Password not match");
      return;
    }

    setState(() => isLoading = true);
    try {
      await _auth.register(email.text.trim(), password.text.trim());
      toggle();
    } catch (e) {
      show(e.toString());
    }
    setState(() => isLoading = false);
  }

  Future<void> handleGoogle() async {
    try {
      await _auth.loginWithGoogle();
    } catch (e) {
      show(e.toString());
    }
  }

  Future<void> handleForgot() async {
    await _auth.forgotPassword(email.text.trim());
    show("Check your email");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌌 BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E3A8A),
                  Color(0xFF4F46E5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🔵 BLOB EFFECT (loang màu)
          Positioned(
            top: -100,
            left: -50,
            child: _blob(300, Colors.blueAccent.withOpacity(0.3)),
          ),
          Positioned(
            bottom: -120,
            right: -50,
            child: _blob(300, Colors.purpleAccent.withOpacity(0.3)),
          ),

          // 🧾 GLASS FORM
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLogin ? "Welcome Back" : "Create Account",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 25),

                          _input(email, "Email", Icons.email),
                          _input(password, "Password", Icons.lock),

                          if (!isLogin)
                            _input(confirm, "Confirm Password", Icons.lock),

                          const SizedBox(height: 20),

                          isLoading
                              ? const CircularProgressIndicator()
                              : _mainButton(
                            isLogin ? "Sign In" : "Sign Up",
                            isLogin ? handleLogin : handleRegister,
                          ),

                          const SizedBox(height: 10),

                          _googleButton(handleGoogle),

                          const SizedBox(height: 10),

                          TextButton(
                            onPressed: handleForgot,
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),

                          TextButton(
                            onPressed: toggle,
                            child: Text(
                              isLogin
                                  ? "No account? Sign Up"
                                  : "Have account? Sign In",
                              style:
                              const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔵 Blob background
  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // 🔹 Input
  Widget _input(
      TextEditingController c, String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        obscureText: label.contains("Password"),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 🔥 Button
  Widget _mainButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔵 Google button
  Widget _googleButton(VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.g_mobiledata, size: 28),
        label: const Text("Continue with Google"),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}