import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/artist_model.dart';
import '../../domain/entities/artist_event_entity.dart';

class ArtistsDataSource {
  // ── قائمة الفنانين ─────────────────────────────────────────────
  Future<List<ArtistModel>> getArtists({
    String? serviceType,
    String? city,
  }) async {
    final res = await ApiClient.dio.get(
      'artists',
      queryParameters: {
        if (serviceType != null) 'service_type': serviceType,
        if (city != null) 'city': city,
      },
    );
    final list = res.data['data']['data'] as List<dynamic>;
    return list
        .map((e) => ArtistModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── ملف فنان ───────────────────────────────────────────────────
  Future<ArtistModel> getArtist(int id) async {
    final res = await ApiClient.dio.get('artists/$id');
    return ArtistModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── مواعيد الفنان ──────────────────────────────────────────────
  /// [type] : 'upcoming' | 'past' | 'current'
  Future<List<ArtistEventEntity>> getArtistEvents(
    int artistId, {
    String type = 'upcoming',
  }) async {
    final res = await ApiClient.dio.get(
      'artists/$artistId/events',
      queryParameters: {'type': type},
    );
    final list = res.data['events'] as List<dynamic>? ?? [];
    return list
        .map((e) => ArtistEventEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── الموقع الجغرافي (للعميل) ───────────────────────────────────
  Future<Map<String, dynamic>?> getArtistLocation(int artistId) async {
    final res = await ApiClient.dio.get('artists/$artistId/location');
    return res.data['location'] as Map<String, dynamic>?;
  }

  // ── تحديث موقع الفنان (للفنان) ────────────────────────────────
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    await ApiClient.dio.put('artist/location', data: {
      'latitude':       latitude,
      'longitude':      longitude,
      if (label != null) 'location_label': label,
    });
  }

  // ── إيقاف الموقع (للفنان) ─────────────────────────────────────
  Future<void> disableLocation() async {
    await ApiClient.dio.delete('artist/location');
  }
}
