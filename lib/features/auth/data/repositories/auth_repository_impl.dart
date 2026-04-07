import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Future<void> sendOtp(String phone) => _ds.sendOtp(phone);

  @override
  Future<AuthEntity> verifyOtp(String phone, String otp, String role) =>
      _ds.verifyOtp(phone, otp, role);
}
