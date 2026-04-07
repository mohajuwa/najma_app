import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity>       getOrder(int id);
  Future<OrderEntity>       createOrder(Map<String, dynamic> data);
}
