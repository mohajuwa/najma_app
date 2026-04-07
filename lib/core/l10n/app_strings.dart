
/// نظام الترجمة لنجمة — عربي وإنجليزي
/// الاستخدام:
///   final s = AppStrings.of(context);
///   Text(s.welcome)

import 'package:flutter/material.dart';

class AppStrings {
  final String lang;
  const AppStrings._(this.lang);

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppStrings._(locale.languageCode);
  }

  static AppStrings forLang(String lang) => AppStrings._(lang);

  bool get isAr => lang == 'ar';

  String _t(String ar, String en) => isAr ? ar : en;

  // ── عام ──────────────────────────────────────────────────────
  String get appName         => 'نجمة';
  String get confirm         => _t('تأكيد',             'Confirm');
  String get cancel          => _t('إلغاء',             'Cancel');
  String get save            => _t('حفظ',               'Save');
  String get back            => _t('رجوع',              'Back');
  String get loading         => _t('جاري التحميل...',   'Loading...');
  String get retry           => _t('إعادة المحاولة',    'Retry');
  String get unknownError    => _t('حدث خطأ غير متوقع', 'An unexpected error occurred');
  String get noConnection    => _t('تعذّر الاتصال بالسيرفر', 'Could not connect to server');

  // ── شاشة اللغة ───────────────────────────────────────────────
  String get selectLanguage  => _t('اختر لغتك',         'Choose your language');
  String get selectLangSub   => _t('Select your language', 'اختر لغتك');
  String get arabic          => _t('العربية',            'Arabic');
  String get english         => _t('English',            'الإنجليزية');

  // ── شاشة اختيار الدور ────────────────────────────────────────
  String get whoAreYou       => _t('أنت من؟',           'Who are you?');
  String get choiceToContinue => _t('اختر للمتابعة',    'Choose to continue');
  String get artist          => _t('فنان',              'Artist');
  String get celebrant       => _t('محتفل',             'Celebrant');
  String get artistDesc      => _t('إدارة خدماتك واستقبال الطلبات', 'Manage your services and receive bookings');
  String get celebrantDesc   => _t('احجز تهنئة خاصة لمن تحب',       'Book a special performance for your loved ones');

  // ── شاشة OTP ─────────────────────────────────────────────────
  String get welcomeToNajma  => _t('أهلاً بك في نجمة',  'Welcome to Najma');
  String get enterOtp        => _t('أدخل رمز التحقق',   'Enter verification code');
  String get otpWillBeSent   => _t('سيُرسل رمز تحقق إلى رقم جوالك', 'A verification code will be sent to your phone');
  String get otpSentTo       => _t('تم إرسال رمز مكوّن من 6 أرقام إلى', 'A 6-digit code was sent to');
  String get phoneNumber     => _t('رقم الجوال',        'Phone Number');
  String get phonePlaceholder => '05xxxxxxxx';
  String get sendOtp         => _t('إرسال رمز التحقق',  'Send verification code');
  String get verifyOtp       => _t('تأكيد',             'Verify');
  String get didntReceive    => _t('لم تستلم الرمز؟  ', "Didn't receive it?  ");
  String get resendIn        => _t('إعادة الإرسال بعد', 'Resend in');
  String get resend          => _t('إعادة الإرسال',     'Resend');
  String get seconds         => _t('ث',                 's');
  String get otpInvalid      => _t('رمز التحقق غير صحيح', 'Invalid verification code');
  String get tooManyRequests => _t('طلبات كثيرة، حاول لاحقاً', 'Too many requests, try later');

  // ── الرئيسية ─────────────────────────────────────────────────
  String get home            => _t('الرئيسية',          'Home');
  String get search          => _t('بحث',               'Search');
  String get myOrders        => _t('طلباتي',            'My Orders');
  String get notifications   => _t('الإشعارات',         'Notifications');
  String get profile         => _t('حسابي',             'Profile');

  // ── الفنانين ─────────────────────────────────────────────────
  String get artists         => _t('الفنانون',          'Artists');
  String get available       => _t('متاح',              'Available');
  String get unavailable     => _t('غير متاح',          'Unavailable');
  String get rating          => _t('التقييم',           'Rating');
  String get reviews         => _t('مراجعة',            'Reviews');
  String get bookNow         => _t('احجز الآن',         'Book Now');
  String get noArtists       => _t('لا يوجد فنانون',   'No artists found');

  // ── الطلبات ──────────────────────────────────────────────────
  String get orders          => _t('الطلبات',           'Orders');
  String get noOrders        => _t('لا توجد طلبات',     'No orders yet');
  String get orderDetails    => _t('تفاصيل الطلب',      'Order Details');
  String get total           => _t('الإجمالي',          'Total');
  String get createOrder     => _t('إنشاء طلب',         'Create Order');

  // ── الإشعارات ─────────────────────────────────────────────────
  String get noNotifications => _t('لا توجد إشعارات',  'No notifications');
  String get markAllRead     => _t('تعيين الكل كمقروء', 'Mark all as read');

  // ── حالات الطلب ───────────────────────────────────────────────
  String get statusPending   => _t('قيد الانتظار',  'Pending');
  String get statusAccepted  => _t('مقبول',         'Accepted');
  String get statusPerforming => _t('جاري التنفيذ', 'Performing');
  String get statusDelivered => _t('تم التسليم',    'Delivered');
  String get statusCompleted => _t('مكتمل',         'Completed');
  String get statusRejected  => _t('مرفوض',         'Rejected');

  // ── لوحة الفنان ───────────────────────────────────────────────
  String get artistDashboard => _t('لوحة التحكم',       'Dashboard');
  String get myServices      => _t('خدماتي',            'My Services');
  String get earnings        => _t('أرباحي',            'Earnings');
  String get todayBookings   => _t('حجوزات اليوم',      "Today's Bookings");

  // ── تسجيل الدخول/الخروج ───────────────────────────────────────
  String get logout          => _t('تسجيل الخروج',      'Logout');
  String get logoutSuccess   => _t('تم تسجيل الخروج',   'Logged out successfully');
}

