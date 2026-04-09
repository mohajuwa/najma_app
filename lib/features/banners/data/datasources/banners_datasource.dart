import '../../../../core/network/api_client.dart';
import '../models/banner_model.dart';

class BannersDataSource {
  Future<List<BannerModel>> getBanners() async {
    final res = await ApiClient.dio.get('banners');
    final list = res.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
