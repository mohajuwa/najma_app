import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.artistId,
    required super.clientId,
    required super.status,
    required super.totalAmount,
    super.notes,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id:          j['id']           as int,
    artistId:    j['artist_id']    as int,
    clientId:    j['client_id']    as int,
    status:      j['status']       as String,
    totalAmount: (j['total_amount'] as num).toDouble(),
    notes:       j['notes']        as String?,
    createdAt:   DateTime.parse(j['created_at'] as String),
  );
}
