class OrderDeliverableEntity {
  final int     id;
  final String  fileType;   // 'video' | 'audio'
  final String  url;
  final String  originalName;
  final int?    fileSize;
  final String? fileSizeFmt;
  final String? duration;
  final String? message;
  final DateTime? createdAt;

  const OrderDeliverableEntity({
    required this.id,
    required this.fileType,
    required this.url,
    required this.originalName,
    this.fileSize,
    this.fileSizeFmt,
    this.duration,
    this.message,
    this.createdAt,
  });

  bool get isVideo => fileType == 'video';
  bool get isAudio => fileType == 'audio';

  factory OrderDeliverableEntity.fromJson(Map<String, dynamic> j) {
    return OrderDeliverableEntity(
      id:           j['id'] as int,
      fileType:     j['file_type'].toString(),
      url:          j['url'].toString(),
      originalName: j['original_name'].toString(),
      fileSize:     j['file_size'] as int?,
      fileSizeFmt:  j['file_size_fmt']?.toString(),
      duration:     j['duration']?.toString(),
      message:      j['message']?.toString(),
      createdAt:    j['created_at'] != null
                      ? DateTime.tryParse(j['created_at'].toString())
                      : null,
    );
  }
}
