import 'package:intl/intl.dart';

class NajmaFormatters {
  static String currency(double amount) =>
      '${NumberFormat('#,##0.00', 'ar').format(amount)} ر.س';

  static String phone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('966')) return '+$clean';
    if (clean.startsWith('0'))   return '+966${clean.substring(1)}';
    return '+966$clean';
  }

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'الآن';
    if (diff.inMinutes < 60) return 'منذ \${diff.inMinutes} دقيقة';
    if (diff.inHours   < 24) return 'منذ \${diff.inHours} ساعة';
    return 'منذ \${diff.inDays} يوم';
  }
}
