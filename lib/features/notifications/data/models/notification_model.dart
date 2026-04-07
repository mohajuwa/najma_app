import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.isRead,
    super.type,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
    id:        j['id']         as int,
    title:     j['title']      as String,
    body:      j['body']       as String,
    isRead:    j['is_read']    as bool? ?? false,
    type:      j['type']       as String?,
    createdAt: DateTime.parse(j['created_at'] as String),
  );
}
