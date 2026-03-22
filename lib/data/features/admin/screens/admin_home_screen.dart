import 'package:flutter/material.dart';

import '../../../../routes/app_router.dart';
import '../../auth/controllers/auth_controller.dart';
import '../widgets/admin_guard.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          actions: [
            IconButton(
              onPressed: () async {
                final auth = AuthController();
                await auth.logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.login,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pushNamed(context, AppRouter.adminDashboard);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Coupons'),
              onTap: () {
                Navigator.pushNamed(context, AppRouter.adminCoupons);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () {
                Navigator.pushNamed(context, AppRouter.adminUsers);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Ratings'),
              onTap: () {
                Navigator.pushNamed(context, AppRouter.adminReviews);
              },
            ),
          ],
        ),
      ),
    );
  }
}
