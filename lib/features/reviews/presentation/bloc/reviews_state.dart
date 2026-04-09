import '../../domain/entities/review_entity.dart';
import '../../domain/entities/review_status_entity.dart';

abstract class ReviewsState {
  const ReviewsState();
}

class ReviewsInitial    extends ReviewsState { const ReviewsInitial(); }
class ReviewsLoading    extends ReviewsState { const ReviewsLoading(); }
class ReviewsSubmitting extends ReviewsState { const ReviewsSubmitting(); }

class ReviewsLoaded extends ReviewsState {
  final List<ReviewEntity> reviews;
  const ReviewsLoaded(this.reviews);
}

/// حالة التقييم: هل يمكن التقييم، هل قيّم مسبقاً، هل في نافذة التعديل
class ReviewStatusLoaded extends ReviewsState {
  final ReviewStatusEntity status;
  const ReviewStatusLoaded(this.status);
}

class ReviewsError extends ReviewsState {
  final String message;
  const ReviewsError(this.message);
}

class ReviewSubmitted extends ReviewsState {
  final String message;
  const ReviewSubmitted(this.message);
}

class ReviewSubmitError extends ReviewsState {
  final String message;
  const ReviewSubmitError(this.message);
}
