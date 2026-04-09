class ReviewStatusEntity {
  final bool   canReview;      // هل أكمل طلباً مع الفنان؟
  final bool   hasReviewed;    // هل قيّم مسبقاً؟
  final bool   canEdit;        // هل في نافذة التعديل (48 ساعة)؟
  final String? editDeadline;  // ISO8601 — متى تنتهي نافذة التعديل
  final String? reason;        // سبب عدم القدرة على التقييم

  const ReviewStatusEntity({
    required this.canReview,
    required this.hasReviewed,
    required this.canEdit,
    this.editDeadline,
    this.reason,
  });
}
