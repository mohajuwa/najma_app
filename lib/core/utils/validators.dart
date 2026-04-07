class NajmaValidators {
  static String? phone(String? val) {
    if (val == null || val.isEmpty) return 'أدخل رقم الجوال';
    if (!RegExp(r'^05[0-9]{8}$').hasMatch(val)) return 'رقم جوال غير صحيح';
    return null;
  }

  static String? required(String? val, [String label = 'هذا الحقل']) {
    if (val == null || val.trim().isEmpty) return '$label مطلوب';
    return null;
  }

  static String? minLength(String? val, int min) {
    if (val == null || val.length < min) return 'يجب أن يكون $min أحرف على الأقل';
    return null;
  }
}
