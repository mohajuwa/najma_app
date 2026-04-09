import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_datasource.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final _ds = CheckoutDataSource();

  @override
  Future<Map<String, dynamic>> createOrder({
    required int serviceId,
    required String fanName,
    String? fanPhone,
    String? message,
    required String timing,
  }) =>
      _ds.createOrder(
        serviceId: serviceId,
        fanName  : fanName,
        fanPhone : fanPhone,
        message  : message,
        timing   : timing,
      );
}
