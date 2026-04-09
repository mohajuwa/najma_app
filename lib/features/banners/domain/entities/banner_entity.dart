class BannerEntity {
  final int id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? linkUrl;
  final String linkType; // none | artist | url | lounge
  final int? linkId;

  const BannerEntity({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.linkUrl,
    required this.linkType,
    this.linkId,
  });
}
