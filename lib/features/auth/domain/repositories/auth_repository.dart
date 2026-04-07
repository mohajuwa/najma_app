import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<void>       sendOtp(String phone);
  Future<AuthEntity> verifyOtp(String phone, String otp, String role);
}
