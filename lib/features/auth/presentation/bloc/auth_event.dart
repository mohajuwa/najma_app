part of 'auth_bloc.dart';

abstract class AuthEvent {}

class SendOtpEvent extends AuthEvent {
  final String phone;
  SendOtpEvent(this.phone);
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;
  final String role;
  VerifyOtpEvent({required this.phone, required this.otp, required this.role});
}

class ResetAuthEvent extends AuthEvent {}
