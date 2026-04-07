import '../../domain/entities/artist_entity.dart';

class ArtistModel extends ArtistEntity {
  const ArtistModel({
    required super.id,
    required super.nameAr,
    super.nameEn,
    super.bio,
    super.avatar,
    required super.rating,
    required super.reviewsCount,
    required super.isAvailable,
    required super.services,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> j) => ArtistModel(
    id:           j['id']           as int,
    nameAr:       j['name_ar']      as String,
    nameEn:       j['name_en']      as String?,
    bio:          j['bio']          as String?,
    avatar:       j['avatar']       as String?,
    rating:       (j['rating']      as num?)?.toDouble() ?? 0.0,
    reviewsCount: j['reviews_count'] as int? ?? 0,
    isAvailable:  j['is_available'] as bool? ?? false,
    services:     (j['services']    as List<dynamic>?)
                    ?.map((e) => e.toString()).toList() ?? [],
  );
}
