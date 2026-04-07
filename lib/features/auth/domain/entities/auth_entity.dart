class AuthEntity {
  final String token;
  final String role;
  final int    userId;
  final String phone;

  const AuthEntity({
    required this.token,
    required this.role,
    required this.userId,
    required this.phone,
  });
}
