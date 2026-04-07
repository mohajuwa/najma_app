import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationsDataSource {
  Future<List<NotificationModel>> getNotifications() async {
    final res  = await ApiClient.dio.get('notifications');
    final list = res.data['data'] as List<dynamic>;
    return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markAsRead(int id) =>
      ApiClient.dio.patch('notifications/\$id/read');

  Future<void> markAllRead() =>
      ApiClient.dio.post('notifications/mark-all-read');
}
