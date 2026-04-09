import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/order_deliverable_entity.dart';

class OrderDeliverableDataSource {
  // ── الفنان يرفع ملف ────────────────────────────────────────────
  Future<OrderDeliverableEntity> upload({
    required int    orderId,
    required String filePath,
    String? message,
    String? duration,
  }) async {
    final formData = FormData.fromMap({
      'file':    await MultipartFile.fromFile(filePath),
      if (message  != null) 'message':  message,
      if (duration != null) 'duration': duration,
    });

    final res = await ApiClient.dio.post(
      'orders/$orderId/deliverables',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
        sendTimeout:    const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );

    return OrderDeliverableEntity.fromJson(
      res.data['deliverable'] as Map<String, dynamic>,
    );
  }

  // ── جلب الملفات المُسلَّمة ─────────────────────────────────────
  Future<List<OrderDeliverableEntity>> getDeliverables(int orderId) async {
    final res = await ApiClient.dio.get('orders/$orderId/deliverables');
    final list = res.data['deliverables'] as List<dynamic>? ?? [];
    return list
        .map((e) => OrderDeliverableEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── الفنان يحذف ملف ───────────────────────────────────────────
  Future<void> deleteDeliverable(int orderId, int id) async {
    await ApiClient.dio.delete('orders/$orderId/deliverables/$id');
  }
}
