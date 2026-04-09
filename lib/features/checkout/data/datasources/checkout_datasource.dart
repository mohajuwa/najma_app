import '../../../../core/network/api_client.dart';

class CheckoutDataSource {
  Future<Map<String, dynamic>> createOrder({
    required int serviceId,
    required String fanName,
    String? fanPhone,
    String? message,
    required String timing,
  }) async {
    final res = await ApiClient.dio.post('orders', data: {
      'service_id': serviceId,
      'fan_name'  : fanName,
      'fan_phone' : fanPhone,
      'message'   : message,
      'timing'    : timing,
    });
    return res.data['data'] as Map<String, dynamic>;
  }
}
