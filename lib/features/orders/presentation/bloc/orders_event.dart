part of 'orders_bloc.dart';
abstract class OrdersEvent {}
class LoadOrdersEvent  extends OrdersEvent {}
class LoadOrderEvent   extends OrdersEvent { final int id; LoadOrderEvent(this.id); }
class CreateOrderEvent extends OrdersEvent {
  final Map<String, dynamic> data;
  CreateOrderEvent(this.data);
}
