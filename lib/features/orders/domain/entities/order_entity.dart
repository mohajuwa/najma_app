class OrderEntity {
  final int    id;
  final int    artistId;
  final int    clientId;
  final String status;
  final double totalAmount;
  final String? notes;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    required this.artistId,
    required this.clientId,
    required this.status,
    required this.totalAmount,
    this.notes,
    required this.createdAt,
  });
}
