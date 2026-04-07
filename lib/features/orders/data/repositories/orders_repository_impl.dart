import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersDataSource _ds;
  OrdersRepositoryImpl(this._ds);

  @override Future<List<OrderEntity>> getOrders()              => _ds.getOrders();
  @override Future<OrderEntity>       getOrder(int id)         => _ds.getOrder(id);
  @override Future<OrderEntity>       createOrder(Map<String, dynamic> d) => _ds.createOrder(d);
}
