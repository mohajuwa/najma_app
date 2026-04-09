import '../../../../core/network/api_client.dart';

class DashboardDataSource {
  Future<Map<String, dynamic>> getStats() async {
    final res = await ApiClient.dio.get('artist/stats');
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getLiveOrders() async {
    final res = await ApiClient.dio.get('artist/orders/live');
    return res.data['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getOrders({String? status, int page = 1}) async {
    final res = await ApiClient.dio.get('artist/orders', queryParameters: {
      if (status != null) 'status': status,
      'page': page,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    await ApiClient.dio.patch('orders/$orderId/status', data: {'status': status});
  }

  /// جلب ملف الفنان الحالي (للحصول على is_available)
  Future<Map<String, dynamic>> getMyProfile() async {
    final res = await ApiClient.dio.get('artists/profile');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// تحديث حالة التوفر
  Future<void> updateAvailability(bool isAvailable) async {
    await ApiClient.dio.put('artists/profile', data: {
      'is_available': isAvailable,
    });
  }
}
