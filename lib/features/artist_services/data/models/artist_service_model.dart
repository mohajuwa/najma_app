import '../../domain/entities/artist_service_entity.dart';

class ArtistServiceModel extends ArtistServiceEntity {
  const ArtistServiceModel({
    required super.id,
    required super.type,
    required super.nameAr,
    super.nameEn,
    required super.price,
    super.descriptionAr,
    required super.isActive,
  });

  factory ArtistServiceModel.fromJson(Map<String, dynamic> j) =>
      ArtistServiceModel(
        id:            j['id']           as int,
        type:          j['type']         as String,
        nameAr:        j['name_ar']      as String,
        nameEn:        j['name_en']      as String?,
        price:         (j['price'] as num).toDouble(),
        descriptionAr: j['description_ar'] as String?,
        isActive:      j['is_active']    as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
    'type':           type,
    'name_ar':        nameAr,
    if (nameEn != null) 'name_en': nameEn,
    'price':          price,
    if (descriptionAr != null) 'description_ar': descriptionAr,
    'is_active':      isActive,
  };
}
