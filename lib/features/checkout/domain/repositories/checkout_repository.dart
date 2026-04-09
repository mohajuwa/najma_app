abstract class CheckoutRepository {
  Future<Map<String, dynamic>> createOrder({
    required int serviceId,
    required String fanName,
    String? fanPhone,
    String? message,
    required String timing,
  });
}
