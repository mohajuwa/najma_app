class ArtistEventEntity {
  final int     id;
  final DateTime? timing;
  final String? timingDisplay;
  final String? serviceName;
  final String? serviceCategory;
  final String  status;
  final String? occasion;

  const ArtistEventEntity({
    required this.id,
    this.timing,
    this.timingDisplay,
    this.serviceName,
    this.serviceCategory,
    required this.status,
    this.occasion,
  });

  bool get isUpcoming => status == 'confirmed' || status == 'in_progress';

  factory ArtistEventEntity.fromJson(Map<String, dynamic> j) {
    return ArtistEventEntity(
      id:              j['id'] as int,
      timing:          j['timing'] != null
                         ? DateTime.tryParse(j['timing'].toString())
                         : null,
      timingDisplay:   j['timing_display']?.toString(),
      serviceName:     j['service_name']?.toString(),
      serviceCategory: j['service_type']?.toString(),
      status:          j['status']?.toString() ?? 'pending',
      occasion:        j['occasion']?.toString(),
    );
  }
}
