class AuthEntity {
  final String token;
  final String role;     // الدور الـ active الذي اختاره المستخدم
  final int    userId;
  final String phone;
  final bool   isArtist; // هل لديه سجل فنان؟
  final bool   isFan;    // الكل يقدر يكون محتفل

  const AuthEntity({
    required this.token,
    required this.role,
    required this.userId,
    required this.phone,
    this.isArtist = false,
    this.isFan    = true,
  });
}
