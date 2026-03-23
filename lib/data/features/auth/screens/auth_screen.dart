import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/services/admin_service.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../routes/app_router.dart';
import '../controllers/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthController _auth = AuthController();
  final AdminService _adminService = AdminService();

  bool isLogin = true;
  bool isLoading = false;

  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  void toggle() => setState(() => isLogin = !isLogin);

  void showCenter(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Text(
          msg,
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );

    // auto close sau 2s
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  Future<void> handleLogin() async {
    setState(() => isLoading = true);
    try {
      await _auth.login(email.text.trim(), password.text.trim());
      final isAdmin = await _adminService.isAdmin();

      Navigator.pushReplacementNamed(
        context,
        isAdmin ? AppRouter.admin : AppRouter.home,
      );

    } catch (e) {
      showCenter(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> handleRegister() async {
    if (password.text != confirm.text) {
      showCenter("Password not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      await _auth.register(
        email.text.trim(),
        password.text.trim(),
        confirm.text.trim(),
      );
      toggle();
    } catch (e) {
      showCenter(e.toString());
    } finally {
      setState(() => isLoading = false); // 🔥 luôn chạy
    }
  }

  Future<void> handleGoogle() async {
    setState(() => isLoading = true);
    try {
      await _auth.loginWithGoogle();
      final isAdmin = await _adminService.isAdmin();

      Navigator.pushReplacementNamed(
        context,
        isAdmin ? AppRouter.admin : AppRouter.home,
      );

    } catch (e) {
      showCenter(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> handleForgot() async {
    if (email.text.trim().isEmpty || !email.text.contains("@")) {
      showCenter("Please enter a valid email");
      return;
    }

    try {
      await _auth.forgotPassword(email.text.trim());
      showCenter("Check your email to reset password");
    } catch (e) {
      showCenter(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? Colors.white70 : const Color(0xFF475569);
    final glassColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.75);
    final borderColor =
        isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.06);
    final bgGradient = isDark
        ? const LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E3A8A),
              Color(0xFF4F46E5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFFFFF7ED),
              Color(0xFFFDE68A),
              Color(0xFF99F6E4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Scaffold(
      body: Stack(
        children: [
          // 🌌 BACKGROUND GRADIENT
          Container(
            decoration: BoxDecoration(gradient: bgGradient),
          ),

          // 🔵 BLOB EFFECT (loang màu)
          Positioned(
            top: -100,
            left: -50,
            child: _blob(
              300,
              isDark
                  ? Colors.blueAccent.withOpacity(0.3)
                  : Colors.orangeAccent.withOpacity(0.25),
            ),
          ),
          Positioned(
            bottom: -120,
            right: -50,
            child: _blob(
              300,
              isDark
                  ? Colors.purpleAccent.withOpacity(0.3)
                  : Colors.tealAccent.withOpacity(0.25),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: IconButton(
              onPressed: ThemeController.toggle,
              tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              color: foreground,
            ),
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
                      color: glassColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: borderColor),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLogin ? "Welcome Back" : "Create Account",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: foreground,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            isLogin
                                ? "Sign in to continue shopping"
                                : "Join now to access exclusive deals",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: muted,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 22),

                          _input(context, email, "Email", Icons.email),
                          _input(context, password, "Password", Icons.lock),
                          const SizedBox(height: 8),

                          TextButton(
                            onPressed: handleForgot,
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(color: muted),
                            ),
                          ),
                          if (!isLogin)
                            _input(
                              context,
                              confirm,
                              "Confirm Password",
                              Icons.lock,
                            ),

                          const SizedBox(height: 18),

                          isLoading
                              ? const CircularProgressIndicator()
                              : _mainButton(
                                  text: isLogin ? "Sign In" : "Sign Up",
                                  onTap:
                                      isLogin ? handleLogin : handleRegister,
                                  isDark: isDark,
                                ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black12,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  isLogin
                                      ? "Or sign in with"
                                      : "Or sign up with",
                                  style: TextStyle(color: muted),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          _googleButton(handleGoogle, isDark: isDark),

                          TextButton(
                            onPressed: toggle,
                            child: Text(
                              isLogin
                                  ? "No account? Sign Up"
                                  : "Have account? Sign In",
                              style: TextStyle(color: muted),
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
    BuildContext context,
    TextEditingController c,
    String label,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final hintColor = isDark ? Colors.white54 : const Color(0xFF64748B);
    final iconColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final fillColor =
        isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F5F9);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(
        color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
      ),
    );
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        obscureText: label.contains("Password"),
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          hintText: "Enter $label",
          hintStyle: TextStyle(color: hintColor),
          labelStyle: TextStyle(color: hintColor),
          floatingLabelStyle: TextStyle(color: textColor),
          prefixIcon: Icon(icon, color: iconColor),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(
              color: isDark ? Colors.white70 : const Color(0xFF0F766E),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 Button
  Widget _mainButton({
    required String text,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final gradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          )
        : const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          );

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
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
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
  Widget _googleButton(VoidCallback onTap, {required bool isDark}) {
    final color = isDark ? Colors.red : const Color(0xFFB91C1C);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.g_mobiledata, size: 28),
          label: const Text("Continue with Google"),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}