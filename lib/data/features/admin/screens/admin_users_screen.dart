import 'package:flutter/material.dart';

import '../../../models/admin_user_model.dart';
import '../../../repositories/admin_user_repository.dart';
import '../widgets/admin_guard.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminUserRepository _repo = AdminUserRepository();

  List<AdminUser> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);
    try {
      final data = await _repo.getUsers();
      setState(() => users = data);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load users')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> toggleBan(AdminUser user, bool value) async {
    try {
      await _repo.setUserBanned(user.id, value);
      await loadUsers();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Users'),
          actions: [
            IconButton(
              onPressed: loadUsers,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : users.isEmpty
                ? const Center(child: Text('No users'))
                : ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user.email.isEmpty ? user.id : user.email),
                        subtitle: Text('Role: ${user.role}'),
                        trailing: Switch(
                          value: user.isBanned,
                          onChanged: (value) => toggleBan(user, value),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
