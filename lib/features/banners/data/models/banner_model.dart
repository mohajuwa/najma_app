import '../../domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.title,
    super.description,
    required super.imageUrl,
    super.linkUrl,
    required super.linkType,
    super.linkId,
  });

  factory BannerModel.fromJson(Map<String, dynamic> j) {
    return BannerModel(
      id:          j['id'] as int,
      title:       j['title'] as String? ?? '',
      description: j['description'] as String?,
      imageUrl:    j['image_url'] as String? ?? '',
      linkUrl:     j['link_url'] as String?,
      linkType:    j['link_type'] as String? ?? 'none',
      linkId:      j['link_id'] as int?,
    );
  }
}
