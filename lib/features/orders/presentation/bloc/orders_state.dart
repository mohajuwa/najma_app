part of 'orders_bloc.dart';
abstract class OrdersState {}
class OrdersInitial  extends OrdersState {}
class OrdersLoading  extends OrdersState {}
class OrdersLoaded   extends OrdersState { final List<OrderEntity> orders; OrdersLoaded(this.orders); }
class OrderLoaded    extends OrdersState { final OrderEntity order; OrderLoaded(this.order); }
class OrderCreated   extends OrdersState { final OrderEntity order; OrderCreated(this.order); }
class OrdersError    extends OrdersState { final String message; OrdersError(this.message); }
