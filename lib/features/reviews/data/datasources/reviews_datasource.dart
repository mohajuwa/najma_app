import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/review_model.dart';
import '../../domain/entities/review_status_entity.dart';

class ReviewsDataSource {
  Dio get _dio => ApiClient.dio;

  // جلب تقييمات فنان
  Future<List<ReviewModel>> getReviews(int artistId) async {
    final res  = await _dio.get('artists/$artistId/reviews');
    final list = (res.data['data'] as List?) ?? [];
    return list.map((e) => ReviewModel.fromJson(e)).toList();
  }

  // حالة التقييم للمستخدم الحالي
  Future<ReviewStatusEntity> getReviewStatus(int artistId) async {
    final res  = await _dio.get('artists/$artistId/reviews/status');
    final data = res.data['data'] as Map<String, dynamic>;
    return ReviewStatusEntity(
      canReview:    data['can_review']   as bool? ?? false,
      hasReviewed:  data['has_reviewed'] as bool? ?? false,
      canEdit:      data['can_edit']     as bool? ?? false,
      editDeadline: data['edit_deadline'] as String?,
      reason:       data['reason']       as String?,
    );
  }

  // إرسال / تعديل تقييم
  Future<ReviewModel> addReview(int artistId, int rating, String? comment) async {
    final res = await _dio.post(
      'artists/$artistId/reviews',
      data: {'rating': rating, 'comment': comment},
    );
    return ReviewModel.fromJson(res.data['data']);
  }
}
