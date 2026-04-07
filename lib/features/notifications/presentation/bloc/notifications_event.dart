part of 'notifications_bloc.dart';
abstract class NotificationsEvent {}
class LoadNotificationsEvent  extends NotificationsEvent {}
class MarkReadEvent            extends NotificationsEvent { final int id; MarkReadEvent(this.id); }
class MarkAllReadEvent         extends NotificationsEvent {}
