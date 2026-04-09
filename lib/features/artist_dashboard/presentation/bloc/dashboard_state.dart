part of 'dashboard_bloc.dart';

abstract class DashboardState {}

class DashboardInitial  extends DashboardState {}
class DashboardLoading  extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final Map<String, dynamic> stats;
  final List<dynamic>        liveOrders;
  final bool                 isAvailable;
  DashboardLoaded({
    required this.stats,
    required this.liveOrders,
    this.isAvailable = false,
  });
}

/// حالة مؤقتة أثناء تحديث التوفر
class AvailabilityUpdating extends DashboardState {
  final bool isAvailable; // القيمة الجديدة
  AvailabilityUpdating(this.isAvailable);
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
