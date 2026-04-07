class ArtistEntity {
  final int    id;
  final String nameAr;
  final String? nameEn;
  final String? bio;
  final String? avatar;
  final double  rating;
  final int     reviewsCount;
  final bool    isAvailable;
  final List<String> services;

  const ArtistEntity({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.bio,
    this.avatar,
    required this.rating,
    required this.reviewsCount,
    required this.isAvailable,
    required this.services,
  });
}
