class AdminUser {
  final String id;
  final String email;
  final String role;
  final bool isBanned;

  AdminUser({
    required this.id,
    required this.email,
    required this.role,
    required this.isBanned,
  });

  factory AdminUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AdminUser(
      id: id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      isBanned: data['isBanned'] ?? false,
    );
  }
}
