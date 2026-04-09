import '../../../../core/network/api_client.dart';

class OnboardDataSource {
  /// تسجيل الفنان الجديد
  Future<Map<String, dynamic>> registerArtist({
    required String bioAr,
    String? bioEn,
    required String genre,
    String? iban,
    String? bankName,
  }) async {
    final res = await ApiClient.dio.post('artists/register', data: {
      'bio_ar':    bioAr,
      if (bioEn != null && bioEn.isNotEmpty) 'bio_en': bioEn,
      'genre':     genre,
      if (iban != null && iban.isNotEmpty) 'iban': iban,
      if (bankName != null && bankName.isNotEmpty) 'bank_name': bankName,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// إضافة خدمة للفنان
  Future<void> addService({
    required String type,
    required String nameAr,
    required double price,
    String? descriptionAr,
  }) async {
    await ApiClient.dio.post('artists/services', data: {
      'type':    type,
      'name_ar': nameAr,
      'price':   price,
      if (descriptionAr != null && descriptionAr.isNotEmpty)
        'description_ar': descriptionAr,
    });
  }

  /// جلب بيانات الفنان الحالي
  Future<Map<String, dynamic>> getMyProfile() async {
    final res = await ApiClient.dio.get('artist/profile');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// تحديث حالة التوفر
  Future<void> updateAvailability(bool isAvailable) async {
    await ApiClient.dio.put('artists/profile', data: {
      'is_available': isAvailable,
    });
  }
}
