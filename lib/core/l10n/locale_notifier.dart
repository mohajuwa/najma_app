
import 'package:flutter/material.dart';
import '../storage/local_storage.dart';

/// يُستخدم لتغيير لغة التطبيق ديناميكياً بدون إعادة تشغيل
class LocaleNotifier extends ValueNotifier<Locale> {
  static final LocaleNotifier _instance = LocaleNotifier._();
  static LocaleNotifier get instance => _instance;

  LocaleNotifier._()
      : super(Locale(LocalStorage.getLang() ?? 'ar'));

  void setLocale(String langCode) {
    value = Locale(langCode);
  }

  bool get isAr => value.languageCode == 'ar';
  TextDirection get textDirection =>
      isAr ? TextDirection.rtl : TextDirection.ltr;
}

