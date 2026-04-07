part of 'notifications_bloc.dart';
abstract class NotificationsState {}
class NotificationsInitial extends NotificationsState {}
class NotificationsLoading extends NotificationsState {}
class NotificationsLoaded  extends NotificationsState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  NotificationsLoaded(this.notifications)
      : unreadCount = notifications.where((n) => !n.isRead).length;
}
class NotificationsError extends NotificationsState { final String message; NotificationsError(this.message); }
