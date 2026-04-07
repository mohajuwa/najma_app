import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_model.dart';

class AuthDataSource {
  Future<void> sendOtp(String phone) async {
    await ApiClient.dio.post('auth/send-otp', data: {'phone': phone});
  }

  Future<AuthModel> verifyOtp(String phone, String otp, String role) async {
    final res = await ApiClient.dio.post('auth/verify-otp', data: {
      'phone': phone,
      'otp':   otp,
      'role':  role,
    });
    return AuthModel.fromJson(res.data as Map<String, dynamic>);
  }
}
