import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/notifications_datasource.dart';
import '../../domain/entities/notification_entity.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final _ds = NotificationsDataSource();

  NotificationsBloc() : super(NotificationsInitial()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<MarkReadEvent>(_onMark);
    on<MarkAllReadEvent>(_onMarkAll);
  }

  Future<void> _onLoad(LoadNotificationsEvent e, Emitter<NotificationsState> emit) async {
    emit(NotificationsLoading());
    try   { emit(NotificationsLoaded(await _ds.getNotifications())); }
    catch (_) { emit(NotificationsError('تعذّر تحميل الإشعارات')); }
  }

  Future<void> _onMark(MarkReadEvent e, Emitter<NotificationsState> emit) async {
    await _ds.markAsRead(e.id);
    add(LoadNotificationsEvent());
  }

  Future<void> _onMarkAll(MarkAllReadEvent e, Emitter<NotificationsState> emit) async {
    await _ds.markAllRead();
    add(LoadNotificationsEvent());
  }
}
