part of 'onboard_bloc.dart';

abstract class OnboardState {}

class OnboardInitial extends OnboardState {}

class OnboardLoading extends OnboardState {}

/// الخطوة 1 اكتملت — انتقل لإضافة الخدمات
class ProfileSubmitted extends OnboardState {
  final List<Map<String, dynamic>> localServices; // الخدمات المضافة محلياً
  ProfileSubmitted({this.localServices = const []});
}

/// خدمة أُضيفت محلياً (لم تُرسل بعد)
class ServiceAdded extends OnboardState {
  final List<Map<String, dynamic>> services;
  ServiceAdded(this.services);
}

/// يُرسل الخدمات للـ API
class ServicesSubmitting extends OnboardState {
  final int current;
  final int total;
  ServicesSubmitting({required this.current, required this.total});
}

/// اكتمل التسجيل بالكامل
class OnboardDone extends OnboardState {}

class OnboardError extends OnboardState {
  final String message;
  OnboardError(this.message);
}
