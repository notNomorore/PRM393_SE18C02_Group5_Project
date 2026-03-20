import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _controller = AuthController();
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  void showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _controller.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      Navigator.pop(context);
    } catch (e) {
      showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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

              const SizedBox(height: 16),

              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration:
                const InputDecoration(labelText: "Confirm Password"),
                validator: (v) =>
                v != passwordController.text ? "Not match" : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: handleRegister,
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}