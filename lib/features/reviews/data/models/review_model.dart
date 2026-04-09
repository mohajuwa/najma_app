import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.rating,
    super.comment,
    required super.userName,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> j) => ReviewModel(
    id:        j['id'] as int? ?? 0,
    rating:    j['rating'] as int? ?? 0,
    comment:   j['comment'] as String?,
    userName:  j['user_name'] as String? ?? 'مستخدم',
    createdAt: j['created_at'] as String? ?? '',
  );
}
