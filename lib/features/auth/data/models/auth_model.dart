import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.token,
    required super.role,
    required super.userId,
    required super.phone,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    return AuthModel(
      token:  data['token'] as String,
      role:   data['role']  as String,
      userId: user['id']    as int,
      phone:  user['phone'] as String,
    );
  }
}
