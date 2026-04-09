import '../../domain/entities/artist_entity.dart';

class ArtistModel extends ArtistEntity {
  const ArtistModel({
    required super.id,
    required super.nameAr,
    super.nameEn,
    super.bio,
    super.avatar,
    super.genre,
    required super.rating,
    required super.reviewsCount,
    required super.isAvailable,
    super.instagram,
    super.snapchat,
    super.twitter,
    super.tiktok,
    super.youtube,
    super.services,
    super.location,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> j) {
    final social    = j['social']   as Map<String, dynamic>? ?? {};
    final locationJ = j['location'] as Map<String, dynamic>?;

    ArtistLocation? location;
    if (locationJ != null) {
      location = ArtistLocation(
        latitude:  _toDouble(locationJ['latitude']),
        longitude: _toDouble(locationJ['longitude']),
        label:     locationJ['label']?.toString(),
      );
    }

    return ArtistModel(
      id:           _toInt(j['id']),
      nameAr:       (j['name_ar'] as String?) ?? '',
      nameEn:       j['name_en']  as String?,
      bio:          j['bio']      as String?,
      avatar:       j['avatar']   as String?,
      genre:        j['genre']    as String?,
      rating:       _toDouble(j['rating']),
      reviewsCount: _toInt(j['reviews_count']),
      isAvailable:  (j['is_available'] as bool?) ?? false,
      instagram:    social['instagram'] as String?,
      snapchat:     social['snapchat']  as String?,
      twitter:      social['twitter']   as String?,
      tiktok:       social['tiktok']    as String?,
      youtube:      social['youtube']   as String?,
      services:     _toServiceList(j['services']),
      location:     location,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static List<Map<String, dynamic>> _toServiceList(dynamic v) {
    if (v == null) return [];
    if (v is! List) return [];
    return v.map((e) {
      if (e is Map<String, dynamic>) return e;
      if (e is String) return {'name_ar': e, 'type': '', 'price': 0.0, 'service_category': 'performance'};
      return <String, dynamic>{};
    }).toList();
  }
}
