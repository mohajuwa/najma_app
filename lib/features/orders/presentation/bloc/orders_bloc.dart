import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/orders_datasource.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/entities/order_entity.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  late final OrdersRepositoryImpl _repo;

  OrdersBloc() : super(OrdersInitial()) {
    _repo = OrdersRepositoryImpl(OrdersDataSource());
    on<LoadOrdersEvent> (_onLoad);
    on<LoadOrderEvent>  (_onDetail);
    on<CreateOrderEvent>(_onCreate);
  }

  Future<void> _onLoad(LoadOrdersEvent e, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try   { emit(OrdersLoaded(await _repo.getOrders())); }
    catch (_) { emit(OrdersError('تعذّر تحميل الطلبات')); }
  }

  Future<void> _onDetail(LoadOrderEvent e, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try   { emit(OrderLoaded(await _repo.getOrder(e.id))); }
    catch (_) { emit(OrdersError('تعذّر تحميل الطلب')); }
  }

  Future<void> _onCreate(CreateOrderEvent e, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try   { emit(OrderCreated(await _repo.createOrder(e.data))); }
    catch (_) { emit(OrdersError('تعذّر إنشاء الطلب')); }
  }
}
