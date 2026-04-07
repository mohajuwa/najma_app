class NotificationEntity {
  final int    id;
  final String title;
  final String body;
  final bool   isRead;
  final String? type;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.type,
    required this.createdAt,
  });
}
