abstract class ReviewsEvent {}

class LoadReviewsEvent extends ReviewsEvent {
  final int artistId;
  LoadReviewsEvent(this.artistId);
}

/// تحقق من إمكانية تقييم الفنان (هل له طلب مكتمل؟)
class CheckReviewStatusEvent extends ReviewsEvent {
  final int artistId;
  CheckReviewStatusEvent(this.artistId);
}

class SubmitReviewEvent extends ReviewsEvent {
  final int    artistId;
  final int    rating;
  final String? comment;
  SubmitReviewEvent(this.artistId, this.rating, this.comment);
}
