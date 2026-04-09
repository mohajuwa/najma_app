import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/dashboard_datasource.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final _ds = DashboardDataSource();

  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoad);
    on<RefreshDashboardEvent>(_onRefresh);
    on<UpdateOrderStatusEvent>(_onUpdateStatus);
    on<ToggleAvailabilityEvent>(_onToggleAvailability);
  }

  Future<void> _onLoad(LoadDashboardEvent e, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefresh(RefreshDashboardEvent e, Emitter<DashboardState> emit) async {
    await _fetchAndEmit(emit); // بدون loading لتجنب وميض الـ UI
  }

  Future<void> _onUpdateStatus(UpdateOrderStatusEvent e, Emitter<DashboardState> emit) async {
    try {
      await _ds.updateOrderStatus(e.orderId, e.status);
      add(RefreshDashboardEvent()); // تحديث فوري
    } catch (_) {
      // الخطأ يُعرض في الـ UI مباشرة
    }
  }

  Future<void> _onToggleAvailability(
    ToggleAvailabilityEvent e, Emitter<DashboardState> emit) async {
    // تحديث فوري في الـ UI (Optimistic UI)
    emit(AvailabilityUpdating(e.isAvailable));
    try {
      await _ds.updateAvailability(e.isAvailable);
      // إعادة تحميل الـ dashboard بعد النجاح
      await _fetchAndEmit(emit, isAvailable: e.isAvailable);
    } catch (_) {
      // في حالة الفشل: عكس القيمة وأعد الـ state السابق
      await _fetchAndEmit(emit);
    }
  }

  Future<void> _fetchAndEmit(Emitter<DashboardState> emit,
      {bool? isAvailable}) async {
    try {
      final futures = [
        _ds.getStats(),
        _ds.getLiveOrders(),
        // إذا لم تُمرّر القيمة نجلبها من الـ API
        if (isAvailable == null) _ds.getMyProfile(),
      ];
      final results = await Future.wait(futures);
      final available = isAvailable
          ?? ((results[2] as Map<String, dynamic>)['is_available'] as bool? ?? false);
      emit(DashboardLoaded(
        stats       : results[0] as Map<String, dynamic>,
        liveOrders  : results[1] as List<dynamic>,
        isAvailable : available,
      ));
    } catch (_) {
      emit(DashboardError('تعذّر تحميل البيانات'));
    }
  }
}
