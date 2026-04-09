part of 'onboard_bloc.dart';

abstract class OnboardEvent {}

/// الخطوة 1: تسجيل بيانات الفنان الأساسية
class SubmitProfileEvent extends OnboardEvent {
  final String bioAr;
  final String? bioEn;
  final String genre;
  final String? iban;
  final String? bankName;

  SubmitProfileEvent({
    required this.bioAr,
    this.bioEn,
    required this.genre,
    this.iban,
    this.bankName,
  });
}

/// الخطوة 2: إضافة خدمة
class AddServiceEvent extends OnboardEvent {
  final String type;
  final String nameAr;
  final double price;
  final String? descriptionAr;

  AddServiceEvent({
    required this.type,
    required this.nameAr,
    required this.price,
    this.descriptionAr,
  });
}

/// حذف خدمة من القائمة المحلية (قبل الإرسال)
class RemoveLocalServiceEvent extends OnboardEvent {
  final int index;
  RemoveLocalServiceEvent(this.index);
}

/// إنهاء التسجيل وإرسال جميع الخدمات
class FinishOnboardEvent extends OnboardEvent {}
