import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/admin_service.dart';
import '../../../../routes/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AdminService _adminService = AdminService();

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    await Future.delayed(const Duration(seconds: 1));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final isBanned = await _adminService.isBanned();
      if (isBanned) {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacementNamed(context, AppRouter.login);
        return;
      }

      final isAdmin = await _adminService.isAdmin();
      Navigator.pushReplacementNamed(
        context,
        isAdmin ? AppRouter.admin : AppRouter.home,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}