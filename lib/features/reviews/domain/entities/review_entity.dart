class ReviewEntity {
  final int    id;
  final int    rating;
  final String? comment;
  final String userName;
  final String createdAt;

  const ReviewEntity({
    required this.id,
    required this.rating,
    this.comment,
    required this.userName,
    required this.createdAt,
  });
}
