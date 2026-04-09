import '../../../core/network/api_client.dart';

class SettingsDataSource {
  /// جلب بيانات المستخدم الحالي
  Future<Map<String, dynamic>> getMe() async {
    final res = await ApiClient.dio.get('auth/me');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// تحديث الملف الشخصي (اسم + لغة + بيانات الفنان اختياريًا)
  Future<void> updateProfile({
    String? name,
    String? lang,
    String? bioAr,
    String? bioEn,
    String? genre,
    String? iban,
    String? bankName,
  }) async {
    await ApiClient.dio.put('auth/profile', data: {
      if (name     != null) 'name':      name,
      if (lang     != null) 'lang':      lang,
      if (bioAr    != null) 'bio_ar':    bioAr,
      if (bioEn    != null) 'bio_en':    bioEn,
      if (genre    != null) 'genre':     genre,
      if (iban     != null) 'iban':      iban,
      if (bankName != null) 'bank_name': bankName,
    });
  }

  /// حذف الحساب
  Future<void> deleteAccount() async {
    await ApiClient.dio.post('auth/delete-account');
  }
}
