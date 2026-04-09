class ArtistServiceEntity {
  final int    id;
  final String type;
  final String nameAr;
  final String? nameEn;
  final double price;
  final String? descriptionAr;
  final bool   isActive;

  const ArtistServiceEntity({
    required this.id,
    required this.type,
    required this.nameAr,
    this.nameEn,
    required this.price,
    this.descriptionAr,
    required this.isActive,
  });

  ArtistServiceEntity copyWith({
    String? nameAr,
    String? nameEn,
    double? price,
    String? descriptionAr,
    bool?   isActive,
  }) => ArtistServiceEntity(
    id:            id,
    type:          type,
    nameAr:        nameAr        ?? this.nameAr,
    nameEn:        nameEn        ?? this.nameEn,
    price:         price         ?? this.price,
    descriptionAr: descriptionAr ?? this.descriptionAr,
    isActive:      isActive      ?? this.isActive,
  );
}
