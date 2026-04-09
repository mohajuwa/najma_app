// ── Enums ──────────────────────────────────────────────────────────────────────
enum ServiceCategory { performance, customSong, giftSong, other }

extension ServiceCategoryX on ServiceCategory {
  static ServiceCategory fromString(String? v) {
    switch (v) {
      case 'custom_song': return ServiceCategory.customSong;
      case 'gift_song':   return ServiceCategory.giftSong;
      case 'other':       return ServiceCategory.other;
      default:            return ServiceCategory.performance;
    }
  }

  String get label {
    switch (this) {
      case ServiceCategory.customSong:   return 'أغنية خاصة';
      case ServiceCategory.giftSong:     return 'أغنية هدية';
      case ServiceCategory.other:        return 'خدمات أخرى';
      case ServiceCategory.performance:  return 'أداء مباشر';
    }
  }
}

// ── Location ───────────────────────────────────────────────────────────────────
class ArtistLocation {
  final double  latitude;
  final double  longitude;
  final String? label;
  const ArtistLocation({required this.latitude, required this.longitude, this.label});
}

// ── ArtistEntity ───────────────────────────────────────────────────────────────
class ArtistEntity {
  final int    id;
  final String nameAr;
  final String? nameEn;
  final String? bio;
  final String? avatar;
  final String? genre;
  final double  rating;
  final int     reviewsCount;
  final bool    isAvailable;

  // روابط السوشيال
  final String? instagram;
  final String? snapchat;
  final String? twitter;
  final String? tiktok;
  final String? youtube;

  /// كل عنصر: {'id', 'type', 'service_category', 'name_ar', 'price', 'description_ar'}
  final List<Map<String, dynamic>> services;

  /// الموقع الجغرافي — null إذا أوقفه الفنان
  final ArtistLocation? location;

  const ArtistEntity({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.bio,
    this.avatar,
    this.genre,
    required this.rating,
    required this.reviewsCount,
    required this.isAvailable,
    this.instagram,
    this.snapchat,
    this.twitter,
    this.tiktok,
    this.youtube,
    this.services = const [],
    this.location,
  });

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get hasSocial =>
      instagram != null || snapchat != null ||
      twitter   != null || tiktok   != null || youtube != null;

  List<String> get serviceNames =>
      services.map((s) => s['name_ar']?.toString() ?? '').toList();

  bool get hasLocation => location != null;

  /// خدمات الأغاني فقط
  List<Map<String, dynamic>> get songServices => services
      .where((s) => ['custom_song', 'gift_song']
          .contains(s['service_category']?.toString()))
      .toList();

  // ── copyWith ───────────────────────────────────────────────────────────────

  ArtistEntity copyWith({
    double?          rating,
    int?             reviewsCount,
    bool?            isAvailable,
    ArtistLocation?  location,
    bool             clearLocation = false,
  }) {
    return ArtistEntity(
      id:           id,
      nameAr:       nameAr,
      nameEn:       nameEn,
      bio:          bio,
      avatar:       avatar,
      genre:        genre,
      rating:       rating       ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      isAvailable:  isAvailable  ?? this.isAvailable,
      instagram:    instagram,
      snapchat:     snapchat,
      twitter:      twitter,
      tiktok:       tiktok,
      youtube:      youtube,
      services:     services,
      location:     clearLocation ? null : (location ?? this.location),
    );
  }
}
