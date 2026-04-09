part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class LoadDashboardEvent    extends DashboardEvent {}
class RefreshDashboardEvent extends DashboardEvent {}

class UpdateOrderStatusEvent extends DashboardEvent {
  final int orderId;
  final String status;
  UpdateOrderStatusEvent(this.orderId, this.status);
}

class ToggleAvailabilityEvent extends DashboardEvent {
  final bool isAvailable;
  ToggleAvailabilityEvent(this.isAvailable);
}
