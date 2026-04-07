import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/artist_model.dart';

class ArtistsDataSource {
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
    // قبل: res.data['data'] ← يرجع object مش list
    // بعد: res.data['data']['data'] ← الـ paginated data
    final list = res.data['data']['data'] as List<dynamic>;
    return list
        .map((e) => ArtistModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ArtistModel> getArtist(int id) async {
    print('FETCHING: artists/$id'); // ← أضف
    final res = await ApiClient.dio.get('artists/$id');
    return ArtistModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
