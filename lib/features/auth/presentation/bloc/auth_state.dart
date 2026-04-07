part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class OtpSent extends AuthState {
  final String phone;
  OtpSent(this.phone);
}

class AuthSuccess extends AuthState {
  final String token;
  final String role;
  AuthSuccess({required this.token, required this.role});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
