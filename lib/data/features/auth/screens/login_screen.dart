import 'package:flutter/material.dart';
import '../../../../routes/app_router.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = AuthController();
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await _controller.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      Navigator.pushReplacementNamed(context, AppRouter.home);
    } catch (e) {
      showError(e.toString());
    }

    setState(() => isLoading = false);
  }

  Future<void> handleGoogle() async {
    try {
      await _controller.loginWithGoogle();
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } catch (e) {
      showError("Google login failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Login", style: TextStyle(fontSize: 28)),

              const SizedBox(height: 20),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) =>
                v == null || !v.contains("@") ? "Invalid email" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: (v) =>
                v == null || v.length < 6 ? "Min 6 chars" : null,
              ),

              const SizedBox(height: 20),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: handleLogin,
                child: const Text("Login"),
              ),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: handleGoogle,
                icon: const Icon(Icons.login),
                label: const Text("Google Login"),
              ),

              TextButton(
                onPressed: () {
                  _controller.forgotPassword(emailController.text);
                  showError("Check your email");
                },
                child: const Text("Forgot Password?"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.register);
                },
                child: const Text("Go to Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}