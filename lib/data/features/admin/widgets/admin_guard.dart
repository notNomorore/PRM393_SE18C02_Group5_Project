import 'package:flutter/material.dart';

import '../../../../core/services/admin_service.dart';
import '../../../../routes/app_router.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;
  final AdminService _service = AdminService();

  AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _service.isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAdmin = snapshot.data == true;
        if (!isAdmin) {
          return Scaffold(
            appBar: AppBar(title: const Text('Admin Access')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Access denied'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRouter.home);
                    },
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}
