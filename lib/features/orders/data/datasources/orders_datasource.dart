import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';

class OrdersDataSource {
  Future<List<OrderModel>> getOrders() async {
    final res = await ApiClient.dio.get('orders');
    final list = res.data['data'] as List<dynamic>;
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> getOrder(int id) async {
    final res = await ApiClient.dio.get('orders/\$id');
    return OrderModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    final res = await ApiClient.dio.post('orders', data: data);
    return OrderModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
