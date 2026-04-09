
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
  String get appName          => 'نجم السهرة';
  String get confirm          => _t('تأكيد',              'Confirm');
  String get cancel           => _t('إلغاء',              'Cancel');
  String get save             => _t('حفظ',                'Save');
  String get back             => _t('رجوع',               'Back');
  String get loading          => _t('جاري التحميل...',    'Loading...');
  String get retry            => _t('إعادة المحاولة',     'Retry');
  String get unknownError     => _t('حدث خطأ غير متوقع',  'An unexpected error occurred');
  String get noConnection     => _t('تعذّر الاتصال بالسيرفر', 'Could not connect to server');
  String get tryAgainLater    => _t('حاول مرة أخرى لاحقاً', 'Try again later');
  String get apply            => _t('تطبيق',              'Apply');
  String get edit             => _t('تعديل',              'Edit');
  String get delete           => _t('حذف',                'Delete');
  String get close            => _t('إغلاق',              'Close');
  String get yes              => _t('نعم',                 'Yes');
  String get no               => _t('لا',                  'No');
  String get version          => _t('نسخة التطبيق',       'App Version');

  // ── شاشة اللغة ───────────────────────────────────────────────
  String get selectLanguage   => _t('اختر لغتك',          'Choose your language');
  String get selectLangSub    => _t('Select your language', 'اختر لغتك');
  String get arabic           => _t('العربية',             'Arabic');
  String get english          => _t('English',             'الإنجليزية');
  String get chooseAppLang    => _t('اختر لغة التطبيق',   'Choose app language');

  // ── شاشة اختيار الدور ────────────────────────────────────────
  String get whoAreYou        => _t('أنت من؟',            'Who are you?');
  String get choiceToContinue => _t('اختر للمتابعة',      'Choose to continue');
  String get artist           => _t('فنان',               'Artist');
  String get celebrant        => _t('محتفل',              'Celebrant');
  String get artistDesc       => _t('إدارة خدماتك واستقبال الطلبات', 'Manage your services and receive bookings');
  String get celebrantDesc    => _t('احجز تهنئة خاصة لمن تحب', 'Book a special performance for your loved ones');
  String get startHere        => _t('ابدأ هنا',            'Start Here');

  // ── شاشة OTP ─────────────────────────────────────────────────
  String get welcomeToNajma   => _t('أهلاً بك في نجم السهرة',   'Welcome to Evening Star');
  String get enterOtp         => _t('أدخل رمز التحقق',    'Enter verification code');
  String get otpWillBeSent    => _t('سيُرسل رمز تحقق إلى رقم جوالك', 'A verification code will be sent to your phone');
  String get otpSentTo        => _t('تم إرسال رمز مكوّن من 6 أرقام إلى', 'A 6-digit code was sent to');
  String get phoneNumber      => _t('رقم الجوال',         'Phone Number');
  String get phonePlaceholder => '05xxxxxxxx';
  String get sendOtp          => _t('إرسال رمز التحقق',   'Send verification code');
  String get verifyOtp        => _t('تأكيد',              'Verify');
  String get didntReceive     => _t('لم تستلم الرمز؟  ',  "Didn't receive it?  ");
  String get resendIn         => _t('إعادة الإرسال بعد',  'Resend in');
  String get resend           => _t('إعادة الإرسال',      'Resend');
  String get seconds          => _t('ث',                  's');
  String get otpInvalid       => _t('رمز التحقق غير صحيح', 'Invalid verification code');
  String get tooManyRequests  => _t('طلبات كثيرة، حاول لاحقاً', 'Too many requests, try later');

  // ── التنقل / التبويبات ────────────────────────────────────────
  String get home             => _t('الرئيسية',           'Home');
  String get search           => _t('بحث',                'Search');
  String get myOrders         => _t('طلباتي',             'My Orders');
  String get notifications    => _t('الإشعارات',          'Notifications');
  String get profile          => _t('حسابي',              'Profile');

  // ── الصفحة الرئيسية ──────────────────────────────────────────
  String get discoverArtists  => _t('اكتشف الفنانين',     'Discover Artists');
  String get searchHint       => _t('ابحث عن فنان...',    'Search for an artist...');
  String get allGenres        => _t('الكل',               'All');
  String get welcomeBack      => _t('مرحباً بك',          'Welcome back');
  String get findPerfectArtist => _t('ابحث عن فنانك المثالي', 'Find your perfect artist');
  String get featuredBanners  => _t('إعلانات مميزة',      'Featured Banners');

  // ── الفنانين ─────────────────────────────────────────────────
  String get artists          => _t('الفنانون',           'Artists');
  String get available        => _t('متاح',               'Available');
  String get unavailable      => _t('غير متاح',           'Unavailable');
  String get rating           => _t('التقييم',            'Rating');
  String get reviews          => _t('مراجعة',             'Reviews');
  String get bookNow          => _t('احجز الآن',          'Book Now');
  String get noArtists        => _t('لا يوجد فنانون',    'No artists found');
  String get startingFrom     => _t('يبدأ من',            'From');
  String get sar              => _t('ر.س',                'SAR');

  // ── صفحة الفنان ──────────────────────────────────────────────
  String get artistProfile    => _t('الملف الشخصي',       'Profile');
  String get services         => _t('الخدمات',            'Services');
  String get about            => _t('عن الفنان',          'About');
  String get bookService      => _t('احجز',               'Book');
  String get noServices       => _t('لا توجد خدمات',      'No services available');
  String get perEvent         => _t('/ فعالية',           '/ event');

  // ── الطلبات ──────────────────────────────────────────────────
  String get orders           => _t('الطلبات',            'Orders');
  String get noOrders         => _t('لا توجد طلبات',      'No orders yet');
  String get orderDetails     => _t('تفاصيل الطلب',       'Order Details');
  String get total            => _t('الإجمالي',           'Total');
  String get createOrder      => _t('إنشاء طلب',          'Create Order');

  // ── الإشعارات ─────────────────────────────────────────────────
  String get noNotifications  => _t('لا توجد إشعارات',   'No notifications');
  String get markAllRead      => _t('تعيين الكل كمقروء',  'Mark all as read');

  // ── حالات الطلب ───────────────────────────────────────────────
  String get statusPending    => _t('قيد الانتظار',       'Pending');
  String get statusAccepted   => _t('مقبول',              'Accepted');
  String get statusPerforming => _t('جاري التنفيذ',       'Performing');
  String get statusDelivered  => _t('تم التسليم',         'Delivered');
  String get statusCompleted  => _t('مكتمل',              'Completed');
  String get statusRejected   => _t('مرفوض',              'Rejected');

  // ── لوحة الفنان ───────────────────────────────────────────────
  String get artistDashboard  => _t('لوحة التحكم',        'Dashboard');
  String get myServices       => _t('خدماتي',             'My Services');
  String get earnings         => _t('أرباحي',             'Earnings');
  String get todayBookings    => _t('حجوزات اليوم',       "Today's Bookings");
  String get availability     => _t('الإتاحة',            'Availability');
  String get availableNow     => _t('متاح الآن',          'Available Now');
  String get unavailableNow   => _t('غير متاح حالياً',   'Not Available');
  String get totalEarnings    => _t('إجمالي الأرباح',     'Total Earnings');
  String get pendingOrders    => _t('طلبات معلقة',        'Pending Orders');
  String get completedOrders  => _t('طلبات مكتملة',       'Completed Orders');
  String get addService       => _t('إضافة خدمة',         'Add Service');
  String get serviceType      => _t('نوع الخدمة',         'Service Type');
  String get servicePrice     => _t('السعر',              'Price');
  String get noServicesAdded  => _t('لم تضف خدمات بعد',  'No services added yet');

  // ── تسجيل الدخول/الخروج ───────────────────────────────────────
  String get logout           => _t('تسجيل الخروج',       'Logout');
  String get logoutSuccess    => _t('تم تسجيل الخروج',    'Logged out successfully');

  // ── الإعدادات ─────────────────────────────────────────────────
  String get settings         => _t('الإعدادات',          'Settings');
  String get editProfile      => _t('تعديل الملف الشخصي', 'Edit Profile');
  String get language         => _t('اللغة',              'Language');
  String get privacyPolicy    => _t('سياسة الخصوصية',     'Privacy Policy');
  String get termsConditions  => _t('الشروط والأحكام',    'Terms & Conditions');
  String get aboutApp         => _t('حول التطبيق',        'About App');
  String get contactSupport   => _t('تواصل مع الدعم',     'Contact Support');
  String get rateApp          => _t('قيّم التطبيق',       'Rate the App');
  String get deleteAccount    => _t('حذف الحساب نهائياً', 'Delete Account Permanently');
  String get deleteAccountTitle => _t('حذف الحساب',       'Delete Account');
  String get deleteAccountMsg => _t('هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا القرار.', 'Are you sure you want to delete your account? This cannot be undone.');
  String get saveChanges      => _t('حفظ التغييرات',      'Save Changes');
  String get changesSaved     => _t('تم حفظ التغييرات بنجاح ✓', 'Changes saved successfully ✓');
  String get accountSection   => _t('الحساب',             'Account');
  String get appSection       => _t('التطبيق',            'App');

  // ── تعديل الملف الشخصي ────────────────────────────────────────
  String get fullName         => _t('الاسم الكامل',       'Full Name');
  String get fullNameHint     => _t('محمد...',            'John...');
  String get fullNameRequired => _t('أدخل اسمك',          'Enter your name');
  String get phone            => _t('رقم الجوال',         'Phone Number');
  String get basicInfo        => _t('المعلومات الأساسية', 'Basic Information');
  String get artistInfo       => _t('معلومات الفنان',     'Artist Information');
  String get bankInfo         => _t('المعلومات البنكية (اختياري)', 'Bank Information (optional)');
  String get bioAr            => _t('نبذة بالعربي',       'Bio in Arabic');
  String get bioArHint        => _t('أنا فنان...',        'I am an artist...');
  String get bioEn            => _t('نبذة بالإنجليزي (اختياري)', 'Bio in English (optional)');
  String get bioEnHint        => 'I am an artist...';
  String get genre            => _t('التخصص',             'Specialization');
  String get ibanNumber       => _t('رقم IBAN',           'IBAN Number');
  String get bankName         => _t('اسم البنك',          'Bank Name');
  String get bankNameHint     => _t('بنك الراجحي...',     'Al Rajhi Bank...');
  String get artistRole       => _t('فنان',               'Artist');
  String get celebrantRole    => _t('محتفل',              'Celebrant');
  String get tapToEdit        => _t('اضغط لتعديل بياناتك', 'Tap to edit your profile');

  // ── الأونبوردينغ ───────────────────────────────────────────────
  String get completeProfile  => _t('أكمل ملفك الشخصي',  'Complete Your Profile');
  String get step             => _t('خطوة',               'Step');
  String get stepOf           => _t('من',                 'of');
  String get next             => _t('التالي',             'Next');
  String get finish           => _t('إنهاء',              'Finish');
  String get addYourServices  => _t('أضف خدماتك',         'Add Your Services');

  // ── الدفع ─────────────────────────────────────────────────────
  String get checkout         => _t('الدفع',              'Checkout');
  String get payNow           => _t('ادفع الآن',          'Pay Now');
  String get orderSummary     => _t('ملخص الطلب',         'Order Summary');
  String get serviceName      => _t('الخدمة',             'Service');
  String get artist2          => _t('الفنان',             'Artist');
  String get price            => _t('السعر',              'Price');

  // ── تتبع الطلب ───────────────────────────────────────────────
  String get trackOrder       => _t('تتبع الطلب',         'Track Order');
  String get orderStatus      => _t('حالة الطلب',         'Order Status');
}
