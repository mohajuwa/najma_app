import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/artist_service_model.dart';

class ArtistServicesDataSource {
  Dio get _dio => ApiClient.dio;

  /// جلب خدماتي (فنان مسجّل)
  Future<List<ArtistServiceModel>> getMyServices() async {
    final res = await _dio.get('artist/services');
    final list = res.data['data'] as List;
    return list.map((e) => ArtistServiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// إضافة خدمة
  Future<ArtistServiceModel> addService(Map<String, dynamic> data) async {
    final res = await _dio.post('artists/services', data: data);
    return ArtistServiceModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// تحديث خدمة
  Future<ArtistServiceModel> updateService(int id, Map<String, dynamic> data) async {
    final res = await _dio.put('artists/services/$id', data: data);
    return ArtistServiceModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// حذف خدمة
  Future<void> deleteService(int id) async {
    await _dio.delete('artists/services/$id');
  }
}
