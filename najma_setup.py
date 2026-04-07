"""
نجمة Flutter — سكريبت إنشاء المجلدات والملفات المتبقية
شغّله من أي مكان:
    python najma_setup.py
أو حدد المسار يدوياً:
    python najma_setup.py --path "D:/Dammam Projects/Najma Platform/najma_app"
"""

import os
import argparse

# ── المسار الافتراضي ──────────────────────────────────────────────
DEFAULT_PATH = r"D:\Dammam Projects\Najma Platform\najma_app"

# ── الملفات المتبقية مع محتواها ──────────────────────────────────
FILES = {

    # ════════════════════════════════════════════════════════════════
    # CORE — utils & error handling
    # ════════════════════════════════════════════════════════════════
    "lib/core/error/failures.dart": '''\
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure  extends Failure { const ServerFailure(super.message); }
class NetworkFailure extends Failure { const NetworkFailure(super.message); }
class CacheFailure   extends Failure { const CacheFailure(super.message); }
class AuthFailure    extends Failure { const AuthFailure(super.message); }
''',

    "lib/core/utils/validators.dart": '''\
class NajmaValidators {
  static String? phone(String? val) {
    if (val == null || val.isEmpty) return 'أدخل رقم الجوال';
    if (!RegExp(r'^05[0-9]{8}$').hasMatch(val)) return 'رقم جوال غير صحيح';
    return null;
  }

  static String? required(String? val, [String label = 'هذا الحقل']) {
    if (val == null || val.trim().isEmpty) return '$label مطلوب';
    return null;
  }

  static String? minLength(String? val, int min) {
    if (val == null || val.length < min) return 'يجب أن يكون $min أحرف على الأقل';
    return null;
  }
}
''',

    "lib/core/utils/formatters.dart": '''\
import 'package:intl/intl.dart';

class NajmaFormatters {
  static String currency(double amount) =>
      '${NumberFormat('#,##0.00', 'ar').format(amount)} ر.س';

  static String phone(String phone) {
    final clean = phone.replaceAll(RegExp(r'\\D'), '');
    if (clean.startsWith('966')) return '+$clean';
    if (clean.startsWith('0'))   return '+966${clean.substring(1)}';
    return '+966$clean';
  }

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'الآن';
    if (diff.inMinutes < 60) return 'منذ \${diff.inMinutes} دقيقة';
    if (diff.inHours   < 24) return 'منذ \${diff.inHours} ساعة';
    return 'منذ \${diff.inDays} يوم';
  }
}
''',

    "lib/core/widgets/najma_text_field.dart": '''\
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NajmaTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final Widget? suffix;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;

  const NajmaTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.suffix,
    this.prefix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NajmaTextStyles.caption(size: 12, color: NajmaColors.textSecond)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          onChanged: onChanged,
          style: NajmaTextStyles.body(size: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: NajmaTextStyles.body(size: 14, color: NajmaColors.textDim),
            suffixIcon: suffix,
            prefixIcon: prefix,
            filled: true,
            fillColor: NajmaColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: BorderSide(color: NajmaColors.goldDim.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: BorderSide(color: NajmaColors.goldDim.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: const BorderSide(color: NajmaColors.gold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: const BorderSide(color: NajmaColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
''',

    "lib/core/widgets/najma_gold_divider.dart": '''\
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NajmaGoldDivider extends StatelessWidget {
  final double opacity;
  const NajmaGoldDivider({super.key, this.opacity = 0.3});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            NajmaColors.gold.withOpacity(opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
''',

    "lib/core/widgets/najma_status_badge.dart": '''\
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum OrderStatus { pending, accepted, performing, delivered, completed, rejected }

class NajmaStatusBadge extends StatelessWidget {
  final OrderStatus status;
  const NajmaStatusBadge({super.key, required this.status});

  static const _labels = {
    OrderStatus.pending:    'قيد الانتظار',
    OrderStatus.accepted:   'مقبول',
    OrderStatus.performing: 'جاري التنفيذ',
    OrderStatus.delivered:  'تم التسليم',
    OrderStatus.completed:  'مكتمل',
    OrderStatus.rejected:   'مرفوض',
  };

  static const _colors = {
    OrderStatus.pending:    NajmaColors.pending,
    OrderStatus.accepted:   NajmaColors.accepted,
    OrderStatus.performing: NajmaColors.performing,
    OrderStatus.delivered:  NajmaColors.delivered,
    OrderStatus.completed:  NajmaColors.completed,
    OrderStatus.rejected:   NajmaColors.rejected,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _labels[status]!,
        style: NajmaTextStyles.caption(size: 11, color: color),
      ),
    );
  }
}
''',

    # ════════════════════════════════════════════════════════════════
    # FEATURES — Artists
    # ════════════════════════════════════════════════════════════════
    "lib/features/artists/domain/entities/artist_entity.dart": '''\
class ArtistEntity {
  final int    id;
  final String nameAr;
  final String? nameEn;
  final String? bio;
  final String? avatar;
  final double  rating;
  final int     reviewsCount;
  final bool    isAvailable;
  final List<String> services;

  const ArtistEntity({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.bio,
    this.avatar,
    required this.rating,
    required this.reviewsCount,
    required this.isAvailable,
    required this.services,
  });
}
''',

    "lib/features/artists/domain/repositories/artists_repository.dart": '''\
import '../entities/artist_entity.dart';

abstract class ArtistsRepository {
  Future<List<ArtistEntity>> getArtists({String? serviceType, String? city});
  Future<ArtistEntity>       getArtist(int id);
}
''',

    "lib/features/artists/data/models/artist_model.dart": '''\
import '../../domain/entities/artist_entity.dart';

class ArtistModel extends ArtistEntity {
  const ArtistModel({
    required super.id,
    required super.nameAr,
    super.nameEn,
    super.bio,
    super.avatar,
    required super.rating,
    required super.reviewsCount,
    required super.isAvailable,
    required super.services,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> j) => ArtistModel(
    id:           j['id']           as int,
    nameAr:       j['name_ar']      as String,
    nameEn:       j['name_en']      as String?,
    bio:          j['bio']          as String?,
    avatar:       j['avatar']       as String?,
    rating:       (j['rating']      as num?)?.toDouble() ?? 0.0,
    reviewsCount: j['reviews_count'] as int? ?? 0,
    isAvailable:  j['is_available'] as bool? ?? false,
    services:     (j['services']    as List<dynamic>?)
                    ?.map((e) => e.toString()).toList() ?? [],
  );
}
''',

    "lib/features/artists/data/datasources/artists_datasource.dart": '''\
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/artist_model.dart';

class ArtistsDataSource {
  Future<List<ArtistModel>> getArtists({String? serviceType, String? city}) async {
    final res = await ApiClient.dio.get('artists', queryParameters: {
      if (serviceType != null) 'service_type': serviceType,
      if (city != null)        'city': city,
    });
    final list = res.data['data'] as List<dynamic>;
    return list.map((e) => ArtistModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ArtistModel> getArtist(int id) async {
    final res = await ApiClient.dio.get('artists/\$id');
    return ArtistModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
''',

    "lib/features/artists/data/repositories/artists_repository_impl.dart": '''\
import '../../domain/entities/artist_entity.dart';
import '../../domain/repositories/artists_repository.dart';
import '../datasources/artists_datasource.dart';

class ArtistsRepositoryImpl implements ArtistsRepository {
  final ArtistsDataSource _ds;
  ArtistsRepositoryImpl(this._ds);

  @override
  Future<List<ArtistEntity>> getArtists({String? serviceType, String? city}) =>
      _ds.getArtists(serviceType: serviceType, city: city);

  @override
  Future<ArtistEntity> getArtist(int id) => _ds.getArtist(id);
}
''',

    "lib/features/artists/presentation/bloc/artists_event.dart": '''\
part of 'artists_bloc.dart';

abstract class ArtistsEvent {}

class LoadArtistsEvent extends ArtistsEvent {
  final String? serviceType;
  final String? city;
  LoadArtistsEvent({this.serviceType, this.city});
}

class LoadArtistDetailEvent extends ArtistsEvent {
  final int id;
  LoadArtistDetailEvent(this.id);
}
''',

    "lib/features/artists/presentation/bloc/artists_state.dart": '''\
part of 'artists_bloc.dart';

abstract class ArtistsState {}

class ArtistsInitial extends ArtistsState {}
class ArtistsLoading extends ArtistsState {}

class ArtistsLoaded extends ArtistsState {
  final List<ArtistEntity> artists;
  ArtistsLoaded(this.artists);
}

class ArtistDetailLoaded extends ArtistsState {
  final ArtistEntity artist;
  ArtistDetailLoaded(this.artist);
}

class ArtistsError extends ArtistsState {
  final String message;
  ArtistsError(this.message);
}
''',

    "lib/features/artists/presentation/bloc/artists_bloc.dart": '''\
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/artists_datasource.dart';
import '../../data/repositories/artists_repository_impl.dart';
import '../../domain/entities/artist_entity.dart';

part 'artists_event.dart';
part 'artists_state.dart';

class ArtistsBloc extends Bloc<ArtistsEvent, ArtistsState> {
  late final ArtistsRepositoryImpl _repo;

  ArtistsBloc() : super(ArtistsInitial()) {
    _repo = ArtistsRepositoryImpl(ArtistsDataSource());
    on<LoadArtistsEvent>(_onLoad);
    on<LoadArtistDetailEvent>(_onDetail);
  }

  Future<void> _onLoad(LoadArtistsEvent e, Emitter<ArtistsState> emit) async {
    emit(ArtistsLoading());
    try {
      final list = await _repo.getArtists(serviceType: e.serviceType, city: e.city);
      emit(ArtistsLoaded(list));
    } catch (_) {
      emit(ArtistsError('تعذّر تحميل الفنانين'));
    }
  }

  Future<void> _onDetail(LoadArtistDetailEvent e, Emitter<ArtistsState> emit) async {
    emit(ArtistsLoading());
    try {
      final artist = await _repo.getArtist(e.id);
      emit(ArtistDetailLoaded(artist));
    } catch (_) {
      emit(ArtistsError('تعذّر تحميل بيانات الفنان'));
    }
  }
}
''',

    "lib/features/artists/presentation/widgets/artist_card.dart": '''\
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/artist_entity.dart';

class NajmaArtistCard extends StatelessWidget {
  final ArtistEntity artist;
  final VoidCallback? onTap;

  const NajmaArtistCard({super.key, required this.artist, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Avatar
            SizedBox(
              width: 80, height: 90,
              child: artist.avatar != null
                ? CachedNetworkImage(imageUrl: artist.avatar!, fit: BoxFit.cover)
                : Container(
                    color: NajmaColors.surface2,
                    child: const Icon(Icons.person, color: NajmaColors.goldDim, size: 32),
                  ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(artist.nameAr, style: NajmaTextStyles.heading(size: 15)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star, color: NajmaColors.gold, size: 13),
                      const SizedBox(width: 4),
                      Text(artist.rating.toStringAsFixed(1),
                          style: NajmaTextStyles.caption(size: 12, color: NajmaColors.gold)),
                      Text('  (${artist.reviewsCount})',
                          style: NajmaTextStyles.caption()),
                    ]),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      color: artist.isAvailable
                          ? NajmaColors.success.withOpacity(0.15)
                          : NajmaColors.surface2,
                      child: Text(
                        artist.isAvailable ? 'متاح' : 'غير متاح',
                        style: NajmaTextStyles.caption(
                          size: 10,
                          color: artist.isAvailable ? NajmaColors.success : NajmaColors.textDim,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 14),
              child: Icon(Icons.arrow_back_ios, color: NajmaColors.goldDim, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}
''',

    # ════════════════════════════════════════════════════════════════
    # FEATURES — Orders
    # ════════════════════════════════════════════════════════════════
    "lib/features/orders/domain/entities/order_entity.dart": '''\
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
''',

    "lib/features/orders/domain/repositories/orders_repository.dart": '''\
import '../entities/order_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity>       getOrder(int id);
  Future<OrderEntity>       createOrder(Map<String, dynamic> data);
}
''',

    "lib/features/orders/data/models/order_model.dart": '''\
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
''',

    "lib/features/orders/data/datasources/orders_datasource.dart": '''\
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
''',

    "lib/features/orders/data/repositories/orders_repository_impl.dart": '''\
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersDataSource _ds;
  OrdersRepositoryImpl(this._ds);

  @override Future<List<OrderEntity>> getOrders()              => _ds.getOrders();
  @override Future<OrderEntity>       getOrder(int id)         => _ds.getOrder(id);
  @override Future<OrderEntity>       createOrder(Map<String, dynamic> d) => _ds.createOrder(d);
}
''',

    "lib/features/orders/presentation/bloc/orders_event.dart": '''\
part of 'orders_bloc.dart';
abstract class OrdersEvent {}
class LoadOrdersEvent  extends OrdersEvent {}
class LoadOrderEvent   extends OrdersEvent { final int id; LoadOrderEvent(this.id); }
class CreateOrderEvent extends OrdersEvent {
  final Map<String, dynamic> data;
  CreateOrderEvent(this.data);
}
''',

    "lib/features/orders/presentation/bloc/orders_state.dart": '''\
part of 'orders_bloc.dart';
abstract class OrdersState {}
class OrdersInitial  extends OrdersState {}
class OrdersLoading  extends OrdersState {}
class OrdersLoaded   extends OrdersState { final List<OrderEntity> orders; OrdersLoaded(this.orders); }
class OrderLoaded    extends OrdersState { final OrderEntity order; OrderLoaded(this.order); }
class OrderCreated   extends OrdersState { final OrderEntity order; OrderCreated(this.order); }
class OrdersError    extends OrdersState { final String message; OrdersError(this.message); }
''',

    "lib/features/orders/presentation/bloc/orders_bloc.dart": '''\
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/orders_datasource.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/entities/order_entity.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  late final OrdersRepositoryImpl _repo;

  OrdersBloc() : super(OrdersInitial()) {
    _repo = OrdersRepositoryImpl(OrdersDataSource());
    on<LoadOrdersEvent> (_onLoad);
    on<LoadOrderEvent>  (_onDetail);
    on<CreateOrderEvent>(_onCreate);
  }

  Future<void> _onLoad(LoadOrdersEvent e, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try   { emit(OrdersLoaded(await _repo.getOrders())); }
    catch (_) { emit(OrdersError('تعذّر تحميل الطلبات')); }
  }

  Future<void> _onDetail(LoadOrderEvent e, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try   { emit(OrderLoaded(await _repo.getOrder(e.id))); }
    catch (_) { emit(OrdersError('تعذّر تحميل الطلب')); }
  }

  Future<void> _onCreate(CreateOrderEvent e, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    try   { emit(OrderCreated(await _repo.createOrder(e.data))); }
    catch (_) { emit(OrdersError('تعذّر إنشاء الطلب')); }
  }
}
''',

    # ════════════════════════════════════════════════════════════════
    # FEATURES — Notifications
    # ════════════════════════════════════════════════════════════════
    "lib/features/notifications/domain/entities/notification_entity.dart": '''\
class NotificationEntity {
  final int    id;
  final String title;
  final String body;
  final bool   isRead;
  final String? type;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.type,
    required this.createdAt,
  });
}
''',

    "lib/features/notifications/data/models/notification_model.dart": '''\
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.isRead,
    super.type,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
    id:        j['id']         as int,
    title:     j['title']      as String,
    body:      j['body']       as String,
    isRead:    j['is_read']    as bool? ?? false,
    type:      j['type']       as String?,
    createdAt: DateTime.parse(j['created_at'] as String),
  );
}
''',

    "lib/features/notifications/data/datasources/notifications_datasource.dart": '''\
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationsDataSource {
  Future<List<NotificationModel>> getNotifications() async {
    final res  = await ApiClient.dio.get('notifications');
    final list = res.data['data'] as List<dynamic>;
    return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markAsRead(int id) =>
      ApiClient.dio.patch('notifications/\$id/read');

  Future<void> markAllRead() =>
      ApiClient.dio.post('notifications/mark-all-read');
}
''',

    "lib/features/notifications/presentation/bloc/notifications_event.dart": '''\
part of 'notifications_bloc.dart';
abstract class NotificationsEvent {}
class LoadNotificationsEvent  extends NotificationsEvent {}
class MarkReadEvent            extends NotificationsEvent { final int id; MarkReadEvent(this.id); }
class MarkAllReadEvent         extends NotificationsEvent {}
''',

    "lib/features/notifications/presentation/bloc/notifications_state.dart": '''\
part of 'notifications_bloc.dart';
abstract class NotificationsState {}
class NotificationsInitial extends NotificationsState {}
class NotificationsLoading extends NotificationsState {}
class NotificationsLoaded  extends NotificationsState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  NotificationsLoaded(this.notifications)
      : unreadCount = notifications.where((n) => !n.isRead).length;
}
class NotificationsError extends NotificationsState { final String message; NotificationsError(this.message); }
''',

    "lib/features/notifications/presentation/bloc/notifications_bloc.dart": '''\
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/notifications_datasource.dart';
import '../../domain/entities/notification_entity.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final _ds = NotificationsDataSource();

  NotificationsBloc() : super(NotificationsInitial()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<MarkReadEvent>(_onMark);
    on<MarkAllReadEvent>(_onMarkAll);
  }

  Future<void> _onLoad(LoadNotificationsEvent e, Emitter<NotificationsState> emit) async {
    emit(NotificationsLoading());
    try   { emit(NotificationsLoaded(await _ds.getNotifications())); }
    catch (_) { emit(NotificationsError('تعذّر تحميل الإشعارات')); }
  }

  Future<void> _onMark(MarkReadEvent e, Emitter<NotificationsState> emit) async {
    await _ds.markAsRead(e.id);
    add(LoadNotificationsEvent());
  }

  Future<void> _onMarkAll(MarkAllReadEvent e, Emitter<NotificationsState> emit) async {
    await _ds.markAllRead();
    add(LoadNotificationsEvent());
  }
}
''',

    "lib/features/notifications/presentation/screens/notifications_screen.dart": '''\
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/najma_top_bar.dart';
import '../../../../core/utils/formatters.dart';
import '../bloc/notifications_bloc.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsBloc()..add(LoadNotificationsEvent()),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: NajmaColors.black,
          appBar: const NajmaTopBar(title: 'الإشعارات'),
          body: BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoading)
                return const Center(child: CircularProgressIndicator(color: NajmaColors.gold));
              if (state is NotificationsError)
                return Center(child: Text(state.message, style: NajmaTextStyles.body()));
              if (state is NotificationsLoaded) {
                if (state.notifications.isEmpty)
                  return Center(child: Text('لا توجد إشعارات', style: NajmaTextStyles.body(color: NajmaColors.textDim)));
                return ListView.separated(
                  itemCount: state.notifications.length,
                  separatorBuilder: (_, __) => const Divider(color: Color(0xFF1E1E1E), height: 1),
                  itemBuilder: (ctx, i) {
                    final n = state.notifications[i];
                    return ListTile(
                      tileColor: n.isRead ? Colors.transparent : NajmaColors.gold.withOpacity(0.04),
                      leading: Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: n.isRead ? Colors.transparent : NajmaColors.gold,
                        ),
                      ),
                      title: Text(n.title, style: NajmaTextStyles.body(size: 14)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.body, style: NajmaTextStyles.caption()),
                          Text(NajmaFormatters.timeAgo(n.createdAt),
                              style: NajmaTextStyles.caption(size: 10, color: NajmaColors.textDim)),
                        ],
                      ),
                      onTap: () => context.read<NotificationsBloc>().add(MarkReadEvent(n.id)),
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
''',

    # ════════════════════════════════════════════════════════════════
    # ROUTER — update with notifications route
    # ════════════════════════════════════════════════════════════════
    "lib/features/notifications/notifications.dart": '''\
// Barrel export for notifications feature
export 'presentation/screens/notifications_screen.dart';
export 'presentation/bloc/notifications_bloc.dart';
''',

    # ════════════════════════════════════════════════════════════════
    # AUTH — Clean Architecture complete
    # ════════════════════════════════════════════════════════════════
    "lib/features/auth/domain/entities/auth_entity.dart": '''\
class AuthEntity {
  final String token;
  final String role;
  final int    userId;
  final String phone;

  const AuthEntity({
    required this.token,
    required this.role,
    required this.userId,
    required this.phone,
  });
}
''',

    "lib/features/auth/domain/repositories/auth_repository.dart": '''\
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<void>       sendOtp(String phone);
  Future<AuthEntity> verifyOtp(String phone, String otp, String role);
}
''',

    "lib/features/auth/data/models/auth_model.dart": '''\
import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.token,
    required super.role,
    required super.userId,
    required super.phone,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    return AuthModel(
      token:  data['token'] as String,
      role:   data['role']  as String,
      userId: user['id']    as int,
      phone:  user['phone'] as String,
    );
  }
}
''',

    "lib/features/auth/data/datasources/auth_datasource.dart": '''\
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_model.dart';

class AuthDataSource {
  Future<void> sendOtp(String phone) async {
    await ApiClient.dio.post('auth/send-otp', data: {'phone': phone});
  }

  Future<AuthModel> verifyOtp(String phone, String otp, String role) async {
    final res = await ApiClient.dio.post('auth/verify-otp', data: {
      'phone': phone,
      'otp':   otp,
      'role':  role,
    });
    return AuthModel.fromJson(res.data as Map<String, dynamic>);
  }
}
''',

    "lib/features/auth/data/repositories/auth_repository_impl.dart": '''\
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Future<void> sendOtp(String phone) => _ds.sendOtp(phone);

  @override
  Future<AuthEntity> verifyOtp(String phone, String otp, String role) =>
      _ds.verifyOtp(phone, otp, role);
}
''',

    "lib/features/auth/presentation/bloc/auth_event.dart": '''\
part of 'auth_bloc.dart';

abstract class AuthEvent {}

class SendOtpEvent extends AuthEvent {
  final String phone;
  SendOtpEvent(this.phone);
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;
  final String role;
  VerifyOtpEvent({required this.phone, required this.otp, required this.role});
}

class ResetAuthEvent extends AuthEvent {}
''',

    "lib/features/auth/presentation/bloc/auth_state.dart": '''\
part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class OtpSent extends AuthState {
  final String phone;
  OtpSent(this.phone);
}

class AuthSuccess extends AuthState {
  final String token;
  final String role;
  AuthSuccess({required this.token, required this.role});
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
''',

    "lib/features/auth/presentation/bloc/auth_bloc.dart": '''\
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final AuthRepositoryImpl _repo;

  AuthBloc() : super(AuthInitial()) {
    _repo = AuthRepositoryImpl(AuthDataSource());
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResetAuthEvent>((_, emit) => emit(AuthInitial()));
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _repo.sendOtp(event.phone);
      emit(OtpSent(event.phone));
    } on DioException catch (e) {
      emit(AuthError(_parseError(e)));
    } catch (_) {
      emit(AuthError('حدث خطأ غير متوقع'));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final auth = await _repo.verifyOtp(event.phone, event.otp, event.role);
      emit(AuthSuccess(token: auth.token, role: auth.role));
    } on DioException catch (e) {
      emit(AuthError(_parseError(e)));
    } catch (_) {
      emit(AuthError('حدث خطأ غير متوقع'));
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'] as String;
    if (e.response?.statusCode == 422) return 'رمز التحقق غير صحيح';
    if (e.response?.statusCode == 429) return 'طلبات كثيرة، حاول لاحقاً';
    if (e.type == DioExceptionType.connectionTimeout) return 'تعذّر الاتصال بالسيرفر';
    return 'حدث خطأ، حاول مرة أخرى';
  }
}
''',

    # OTP Screen — الشاشة الكاملة (تُستبدل لو موجودة)
    "lib/features/auth/presentation/screens/otp_screen.dart": '''\
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/najma_button.dart';
import '../../../../core/storage/local_storage.dart';
import '../bloc/auth_bloc.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: const _OtpScreenBody(),
    );
  }
}

class _OtpScreenBody extends StatefulWidget {
  const _OtpScreenBody();
  @override
  State<_OtpScreenBody> createState() => _OtpScreenBodyState();
}

class _OtpScreenBodyState extends State<_OtpScreenBody>
    with SingleTickerProviderStateMixin {
  int    _step  = 0;
  String _phone = '';
  String _role  = 'client';

  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  int    _resendTimer = 60;
  Timer? _timer;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    _role = LocalStorage.getRole() ?? 'client';
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    _timer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _resendTimer--);
      if (_resendTimer <= 0) t.cancel();
    });
  }

  void _switchToOtp(String phone) {
    setState(() { _step = 1; _phone = phone; });
    _animCtrl.reset();
    _animCtrl.forward();
    _startResendTimer();
    Future.delayed(const Duration(milliseconds: 300),
        () { if (mounted) _otpFocus[0].requestFocus(); });
  }

  String get _otpValue => _otpCtrls.map((c) => c.text).join();

  void _onOtpChanged(String val, int idx) {
    if (val.length == 1 && idx < 5) _otpFocus[idx + 1].requestFocus();
    if (val.isEmpty  && idx > 0)    _otpFocus[idx - 1].requestFocus();
    if (_otpValue.length == 6)      _submitOtp();
  }

  void _submitPhone() {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 9) return;
    context.read<AuthBloc>().add(SendOtpEvent(phone));
  }

  void _submitOtp() {
    if (_otpValue.length != 6) return;
    context.read<AuthBloc>().add(
      VerifyOtpEvent(phone: _phone, otp: _otpValue, role: _role),
    );
  }

  void _resendOtp() {
    if (_resendTimer > 0) return;
    for (final c in _otpCtrls) c.clear();
    context.read<AuthBloc>().add(SendOtpEvent(_phone));
  }

  Future<void> _handleSuccess(AuthSuccess state) async {
    await LocalStorage.saveToken(state.token);
    await LocalStorage.saveRole(state.role);
    if (!mounted) return;
    context.go(state.role == 'artist' ? '/artist-dashboard' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is OtpSent)
          _switchToOtp(_phone.isEmpty ? _phoneCtrl.text.trim() : _phone);
        if (state is AuthSuccess) _handleSuccess(state);
        if (state is AuthError)
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(state.message,
                style: NajmaTextStyles.body(size: 13, color: Colors.white),
                textDirection: TextDirection.rtl),
            backgroundColor: NajmaColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: NajmaColors.black,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      if (_step == 1)
                        GestureDetector(
                          onTap: () {
                            setState(() => _step = 0);
                            _animCtrl.reset();
                            _animCtrl.forward();
                            context.read<AuthBloc>().add(ResetAuthEvent());
                          },
                          child: const Icon(Icons.arrow_back_ios,
                              color: NajmaColors.gold, size: 20),
                        ),
                      const Spacer(),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      if (_step == 0) _buildPhoneInput() else _buildOtpInput(),
                      const SizedBox(height: 32),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (ctx, state) => NajmaButton(
                          label: _step == 0 ? 'إرسال رمز التحقق' : 'تأكيد',
                          isLoading: state is AuthLoading,
                          onTap: _step == 0 ? _submitPhone : _submitOtp,
                        ),
                      ),
                      if (_step == 1) ...[
                        const SizedBox(height: 20),
                        _buildResend(),
                      ],
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(width: 36, height: 2, color: NajmaColors.gold),
      const SizedBox(height: 16),
      Text(_step == 0 ? 'أهلاً بك في نجمة' : 'أدخل رمز التحقق',
          style: NajmaTextStyles.display(size: 26)),
      const SizedBox(height: 8),
      Text(
        _step == 0
            ? 'سيُرسل رمز تحقق إلى رقم جوالك'
            : 'تم إرسال رمز مكوّن من 6 أرقام إلى\n+966 ${_phone.replaceAll(RegExp(r"^0"), "")}',
        style: NajmaTextStyles.body(size: 14, color: NajmaColors.textSecond),
      ),
    ],
  );

  Widget _buildPhoneInput() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('رقم الجوال',
          style: NajmaTextStyles.caption(size: 12, color: NajmaColors.textSecond)),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.3)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Color(0xFF2A2520)))),
            child: Text('+966',
                style: NajmaTextStyles.body(size: 15, color: NajmaColors.gold)),
          ),
          Expanded(
            child: TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: NajmaTextStyles.body(size: 16)
                  .copyWith(fontFamily: 'PlayfairDisplay', letterSpacing: 1.5),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                hintText: '05xxxxxxxx',
                hintStyle:
                    NajmaTextStyles.body(size: 15, color: NajmaColors.textDim),
              ),
              onSubmitted: (_) => _submitPhone(),
            ),
          ),
        ]),
      ),
    ],
  );

  Widget _buildOtpInput() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('رمز التحقق',
          style: NajmaTextStyles.caption(size: 12, color: NajmaColors.textSecond)),
      const SizedBox(height: 14),
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _OtpBox(
            controller: _otpCtrls[i],
            focusNode:  _otpFocus[i],
            onChanged:  (val) => _onOtpChanged(val, i),
          )),
        ),
      ),
    ],
  );

  Widget _buildResend() => Center(
    child: GestureDetector(
      onTap: _resendTimer == 0 ? _resendOtp : null,
      child: RichText(
        textDirection: TextDirection.rtl,
        text: TextSpan(children: [
          TextSpan(
            text: 'لم تستلم الرمز؟  ',
            style: NajmaTextStyles.body(size: 13, color: NajmaColors.textDim),
          ),
          TextSpan(
            text: _resendTimer > 0
                ? 'إعادة الإرسال بعد $_resendTimer ث'
                : 'إعادة الإرسال',
            style: NajmaTextStyles.body(
              size: 13,
              color: _resendTimer > 0 ? NajmaColors.textDim : NajmaColors.gold,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ]),
      ),
    ),
  );
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode             focusNode;
  final ValueChanged<String>  onChanged;
  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged});
  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(
        () { if (mounted) setState(() => _focused = widget.focusNode.hasFocus); });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46, height: 56,
      decoration: BoxDecoration(
        color: _focused ? const Color(0xFF1C1505) : NajmaColors.surface,
        border: Border.all(
          color: _focused ? NajmaColors.gold : NajmaColors.goldDim.withOpacity(0.25),
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? [BoxShadow(color: NajmaColors.gold.withOpacity(0.15), blurRadius: 12)]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode:  widget.focusNode,
        textAlign:  TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontFamily: 'PlayfairDisplay', fontSize: 22,
          fontWeight: FontWeight.w700, color: NajmaColors.goldBright,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none, counterText: '', contentPadding: EdgeInsets.zero,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
''',

    # ════════════════════════════════════════════════════════════════
    # CORE — l10n + app + router + fixed screens
    # ════════════════════════════════════════════════════════════════
    "lib/core/l10n/app_strings.dart": r"""
/// نظام الترجمة لنجمة — عربي وإنجليزي
/// الاستخدام:
///   final s = AppStrings.of(context);
///   Text(s.welcome)

import 'package:flutter/material.dart';

class AppStrings {
  final String lang;
  const AppStrings._(this.lang);

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppStrings._(locale.languageCode);
  }

  static AppStrings forLang(String lang) => AppStrings._(lang);

  bool get isAr => lang == 'ar';

  String _t(String ar, String en) => isAr ? ar : en;

  // ── عام ──────────────────────────────────────────────────────
  String get appName         => 'نجمة';
  String get confirm         => _t('تأكيد',             'Confirm');
  String get cancel          => _t('إلغاء',             'Cancel');
  String get save            => _t('حفظ',               'Save');
  String get back            => _t('رجوع',              'Back');
  String get loading         => _t('جاري التحميل...',   'Loading...');
  String get retry           => _t('إعادة المحاولة',    'Retry');
  String get unknownError    => _t('حدث خطأ غير متوقع', 'An unexpected error occurred');
  String get noConnection    => _t('تعذّر الاتصال بالسيرفر', 'Could not connect to server');

  // ── شاشة اللغة ───────────────────────────────────────────────
  String get selectLanguage  => _t('اختر لغتك',         'Choose your language');
  String get selectLangSub   => _t('Select your language', 'اختر لغتك');
  String get arabic          => _t('العربية',            'Arabic');
  String get english         => _t('English',            'الإنجليزية');

  // ── شاشة اختيار الدور ────────────────────────────────────────
  String get whoAreYou       => _t('أنت من؟',           'Who are you?');
  String get choiceToContinue => _t('اختر للمتابعة',    'Choose to continue');
  String get artist          => _t('فنان',              'Artist');
  String get celebrant       => _t('محتفل',             'Celebrant');
  String get artistDesc      => _t('إدارة خدماتك واستقبال الطلبات', 'Manage your services and receive bookings');
  String get celebrantDesc   => _t('احجز تهنئة خاصة لمن تحب',       'Book a special performance for your loved ones');

  // ── شاشة OTP ─────────────────────────────────────────────────
  String get welcomeToNajma  => _t('أهلاً بك في نجمة',  'Welcome to Najma');
  String get enterOtp        => _t('أدخل رمز التحقق',   'Enter verification code');
  String get otpWillBeSent   => _t('سيُرسل رمز تحقق إلى رقم جوالك', 'A verification code will be sent to your phone');
  String get otpSentTo       => _t('تم إرسال رمز مكوّن من 6 أرقام إلى', 'A 6-digit code was sent to');
  String get phoneNumber     => _t('رقم الجوال',        'Phone Number');
  String get phonePlaceholder => '05xxxxxxxx';
  String get sendOtp         => _t('إرسال رمز التحقق',  'Send verification code');
  String get verifyOtp       => _t('تأكيد',             'Verify');
  String get didntReceive    => _t('لم تستلم الرمز؟  ', "Didn't receive it?  ");
  String get resendIn        => _t('إعادة الإرسال بعد', 'Resend in');
  String get resend          => _t('إعادة الإرسال',     'Resend');
  String get seconds         => _t('ث',                 's');
  String get otpInvalid      => _t('رمز التحقق غير صحيح', 'Invalid verification code');
  String get tooManyRequests => _t('طلبات كثيرة، حاول لاحقاً', 'Too many requests, try later');

  // ── الرئيسية ─────────────────────────────────────────────────
  String get home            => _t('الرئيسية',          'Home');
  String get search          => _t('بحث',               'Search');
  String get myOrders        => _t('طلباتي',            'My Orders');
  String get notifications   => _t('الإشعارات',         'Notifications');
  String get profile         => _t('حسابي',             'Profile');

  // ── الفنانين ─────────────────────────────────────────────────
  String get artists         => _t('الفنانون',          'Artists');
  String get available       => _t('متاح',              'Available');
  String get unavailable     => _t('غير متاح',          'Unavailable');
  String get rating          => _t('التقييم',           'Rating');
  String get reviews         => _t('مراجعة',            'Reviews');
  String get bookNow         => _t('احجز الآن',         'Book Now');
  String get noArtists       => _t('لا يوجد فنانون',   'No artists found');

  // ── الطلبات ──────────────────────────────────────────────────
  String get orders          => _t('الطلبات',           'Orders');
  String get noOrders        => _t('لا توجد طلبات',     'No orders yet');
  String get orderDetails    => _t('تفاصيل الطلب',      'Order Details');
  String get total           => _t('الإجمالي',          'Total');
  String get createOrder     => _t('إنشاء طلب',         'Create Order');

  // ── الإشعارات ─────────────────────────────────────────────────
  String get noNotifications => _t('لا توجد إشعارات',  'No notifications');
  String get markAllRead     => _t('تعيين الكل كمقروء', 'Mark all as read');

  // ── حالات الطلب ───────────────────────────────────────────────
  String get statusPending   => _t('قيد الانتظار',  'Pending');
  String get statusAccepted  => _t('مقبول',         'Accepted');
  String get statusPerforming => _t('جاري التنفيذ', 'Performing');
  String get statusDelivered => _t('تم التسليم',    'Delivered');
  String get statusCompleted => _t('مكتمل',         'Completed');
  String get statusRejected  => _t('مرفوض',         'Rejected');

  // ── لوحة الفنان ───────────────────────────────────────────────
  String get artistDashboard => _t('لوحة التحكم',       'Dashboard');
  String get myServices      => _t('خدماتي',            'My Services');
  String get earnings        => _t('أرباحي',            'Earnings');
  String get todayBookings   => _t('حجوزات اليوم',      "Today's Bookings");

  // ── تسجيل الدخول/الخروج ───────────────────────────────────────
  String get logout          => _t('تسجيل الخروج',      'Logout');
  String get logoutSuccess   => _t('تم تسجيل الخروج',   'Logged out successfully');
}

""",

    "lib/core/l10n/locale_notifier.dart": r"""
import 'package:flutter/material.dart';
import '../storage/local_storage.dart';

/// يُستخدم لتغيير لغة التطبيق ديناميكياً بدون إعادة تشغيل
class LocaleNotifier extends ValueNotifier<Locale> {
  static final LocaleNotifier _instance = LocaleNotifier._();
  static LocaleNotifier get instance => _instance;

  LocaleNotifier._()
      : super(Locale(LocalStorage.getLang() ?? 'ar'));

  void setLocale(String langCode) {
    value = Locale(langCode);
  }

  bool get isAr => value.languageCode == 'ar';
  TextDirection get textDirection =>
      isAr ? TextDirection.rtl : TextDirection.ltr;
}

""",

    "lib/core/app/najma_app.dart": r"""
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../theme/app_theme.dart';
import '../router/app_router.dart';
import '../l10n/locale_notifier.dart';

class NajmaApp extends StatelessWidget {
  const NajmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleNotifier.instance,
      builder: (_, locale, __) {
        return MaterialApp.router(
          title: 'نجمة',
          debugShowCheckedModeBanner: false,
          theme: NajmaTheme.darkTheme,
          routerConfig: AppRouter.router,
          locale: locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}

""",

    "lib/main.dart": r"""
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app/najma_app.dart';
import 'core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة SharedPreferences قبل أي شيء
  await LocalStorage.init();

  // Force portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const NajmaApp());
}

""",

    "lib/core/router/app_router.dart": r"""
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/language/presentation/screens/language_screen.dart';
import '../../features/role_select/presentation/screens/role_select_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/home/presentation/screens/celebrant_home_screen.dart';
import '../../features/artist_profile/presentation/screens/artist_profile_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/order_tracking/presentation/screens/order_tracking_screen.dart';
import '../../features/artist_dashboard/presentation/screens/artist_dashboard_screen.dart';
import '../../features/artist_onboard/presentation/screens/artist_onboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';

/// قواعد التنقل:
/// context.go()   = استبدال الـ stack (لا يوجد رجوع) ← للـ Splash والـ Home بعد Login
/// context.push() = إضافة للـ stack (يوجد رجوع)     ← للـ Onboarding والـ Details

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [

      // ── نقطة البداية — لا رجوع منها
      GoRoute(
        path: '/splash',
        builder: (c, s) => const SplashScreen(),
      ),

      // ── Onboarding Flow — push حتى يشتغل زر الرجوع
      GoRoute(
        path: '/language',
        builder: (c, s) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/role-select',
        builder: (c, s) => const RoleSelectScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (c, s) => const OtpScreen(),
      ),

      // ── Celebrant Flow — go (لا رجوع لـ OTP بعد الدخول)
      GoRoute(
        path: '/home',
        builder: (c, s) => const CelebrantHomeScreen(),
        routes: [
          GoRoute(
            path: 'artist/:id',
            builder: (c, s) => ArtistProfileScreen(artistId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'checkout',
            builder: (c, s) => const CheckoutScreen(),
          ),
          GoRoute(
            path: 'track/:orderId',
            builder: (c, s) => OrderTrackingScreen(orderId: s.pathParameters['orderId']!),
          ),
          GoRoute(
            path: 'notifications',
            builder: (c, s) => const NotificationsScreen(),
          ),
        ],
      ),

      // ── Artist Flow
      GoRoute(
        path: '/artist-onboard',
        builder: (c, s) => const ArtistOnboardScreen(),
      ),
      GoRoute(
        path: '/artist-dashboard',
        builder: (c, s) => const ArtistDashboardScreen(),
        routes: [
          GoRoute(
            path: 'notifications',
            builder: (c, s) => const NotificationsScreen(),
          ),
        ],
      ),

    ],
  );
}

""",

    "lib/features/language/presentation/screens/language_screen.dart": r"""
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/widgets/najma_button.dart';
import '../../../../core/l10n/locale_notifier.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'ar';

  final _langs = const [
    {'code': 'ar', 'label': 'العربية',  'sub': 'Arabic',       'flag': '🇸🇦'},
    {'code': 'en', 'label': 'English',  'sub': 'الإنجليزية',   'flag': '🇬🇧'},
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NajmaColors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                // Header
                Container(width: 36, height: 2, color: NajmaColors.gold),
                const SizedBox(height: 16),
                Text('اختر لغتك', style: NajmaTextStyles.display(size: 28)),
                const SizedBox(height: 6),
                Text('Choose your language', style: NajmaTextStyles.caption(size: 13)),
                const SizedBox(height: 40),

                // Language tiles
                ..._langs.map((l) => _LangTile(
                  code:     l['code']!,
                  label:    l['label']!,
                  sub:      l['sub']!,
                  flag:     l['flag']!,
                  selected: _selected == l['code'],
                  onTap:    () => setState(() => _selected = l['code']!),
                )),

                const Spacer(flex: 2),

                NajmaButton(
                  label: _selected == 'ar' ? 'تأكيد' : 'Confirm',
                  onTap: () async {
                    await LocalStorage.saveLang(_selected);
                    // تحديث اللغة فوراً في كل التطبيق
                    LocaleNotifier.instance.setLocale(_selected);
                    if (mounted) context.push('/role-select'); // push ← زر الرجوع يشتغل
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String code, label, sub, flag;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({
    required this.code,
    required this.label,
    required this.sub,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? NajmaColors.gold.withOpacity(0.08) : NajmaColors.surface,
          border: Border.all(
            color: selected ? NajmaColors.gold : NajmaColors.goldDim.withOpacity(0.2),
            width: selected ? 1.2 : 0.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: NajmaColors.gold.withOpacity(0.1), blurRadius: 12)]
              : [],
        ),
        child: Row(children: [
          Text(flag, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: NajmaTextStyles.heading(
                        size: 16,
                        color: selected ? NajmaColors.gold : NajmaColors.textPrimary)),
                Text(sub, style: NajmaTextStyles.caption()),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? NajmaColors.gold : NajmaColors.goldDim.withOpacity(0.3),
                width: 1.5,
              ),
              color: selected ? NajmaColors.gold : Colors.transparent,
            ),
            child: selected
                ? const Icon(Icons.check, size: 13, color: Colors.black)
                : null,
          ),
        ]),
      ),
    );
  }
}

""",

    "lib/features/role_select/presentation/screens/role_select_screen.dart": r"""
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_notifier.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s   = AppStrings.of(context);
    final dir = LocaleNotifier.instance.textDirection;

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        backgroundColor: NajmaColors.black,
        // زر الرجوع للجهاز يشتغل تلقائياً لأننا استخدمنا push
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s.whoAreYou,        style: NajmaTextStyles.display(size: 30)),
                const SizedBox(height: 8),
                Text(s.choiceToContinue, style: NajmaTextStyles.caption(size: 12)),
                const SizedBox(height: 56),
                Row(children: [
                  Expanded(child: _RoleCard(
                    emoji:   '🎤',
                    titleAr: s.artist,
                    titleEn: 'ARTIST',
                    desc:    s.artistDesc,
                    badge:   'PERFORMER',
                    onTap:   () => _select(context, 'artist'),
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _RoleCard(
                    emoji:   '🥂',
                    titleAr: s.celebrant,
                    titleEn: 'CELEBRANT',
                    desc:    s.celebrantDesc,
                    badge:   'FAN',
                    onTap:   () => _select(context, 'fan'),
                  )),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _select(BuildContext context, String role) async {
    await LocalStorage.saveRole(role);
    if (context.mounted) context.push('/otp'); // push ← زر الرجوع يشتغل
  }
}

class _RoleCard extends StatefulWidget {
  final String emoji, titleAr, titleEn, desc, badge;
  final VoidCallback onTap;
  const _RoleCard({
    required this.emoji, required this.titleAr, required this.titleEn,
    required this.desc, required this.badge, required this.onTap,
  });
  @override State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapUp:    (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border: Border.all(
            color: _pressed ? NajmaColors.gold : NajmaColors.goldDim.withOpacity(0.2),
            width: _pressed ? 1 : 0.5,
          ),
        ),
        child: Column(children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(widget.titleAr, style: NajmaTextStyles.heading(size: 18)),
          Text(widget.titleEn, style: NajmaTextStyles.label()),
          const SizedBox(height: 8),
          Text(widget.desc,    style: NajmaTextStyles.caption(), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: NajmaColors.goldDim.withOpacity(0.3)),
            ),
            child: Text(widget.badge, style: NajmaTextStyles.label(size: 9)),
          ),
        ]),
      ),
    );
  }
}

""",

    "lib/features/splash/presentation/screens/splash_screen.dart": r"""
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _starCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _particleCtrl;
  late Animation<double> _starAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _starAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _starCtrl, curve: Curves.easeInOut));

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    Future.delayed(AppConstants.splashDuration, _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final lang = LocalStorage.getLang();

    // أول مرة — اختيار اللغة (go = نقطة بداية جديدة)
    if (lang == null) {
      context.go('/language');
      return;
    }

    // الدور لم يختر — ابدأ من language لأن push stack تبنى من هناك
    final role = LocalStorage.getRole();
    if (role == null) {
      context.go('/language');
      return;
    }

    // مسجّل دخول مسبقاً
    final token = LocalStorage.getToken();
    context.go(
      token != null
          ? (role == 'artist' ? '/artist-dashboard' : '/home')
          : '/otp',
    );
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _fadeCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NajmaColors.black,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Particle background
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(_particleCtrl.value),
                child: const SizedBox.expand(),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Star logo
                  AnimatedBuilder(
                    animation: _starAnim,
                    builder: (_, __) => CustomPaint(
                      painter: _StarPainter(_starAnim.value),
                      size: const Size(80, 80),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Wordmark
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        NajmaColors.goldDim,
                        NajmaColors.gold,
                        NajmaColors.goldBright,
                        NajmaColors.gold,
                        NajmaColors.goldDim,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'NAJMA',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 10,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'نجمة',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: NajmaColors.gold,
                      letterSpacing: 2,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 80,
                    height: 1,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          NajmaColors.gold,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'حيث تلتقي الموهبة بلحظاتك المميزة',
                    style: TextStyle(
                      fontSize: 12,
                      color: NajmaColors.textDim,
                      fontFamily: 'Tajawal',
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final double glow;
  _StarPainter(this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NajmaColors.gold.withOpacity(glow)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final glowPaint = Paint()
      ..color = NajmaColors.gold.withOpacity(glow * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = _starPath(size);
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Center dot
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      Paint()..color = NajmaColors.goldBright.withOpacity(glow),
    );
  }

  Path _starPath(Size s) {
    final path = Path();
    final cx = s.width / 2;
    final cy = s.height / 2;
    const points = 5;
    final outer = s.width * 0.45;
    final inner = s.width * 0.18;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? outer : inner;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.glow != glow;
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final _rng = math.Random(42);
  late final List<_Particle> particles;

  _ParticlePainter(this.progress) {
    particles = List.generate(
      60,
      (i) => _Particle(
        x: _rng.nextDouble(),
        baseY: _rng.nextDouble(),
        speed: _rng.nextDouble() * 0.3 + 0.05,
        size: _rng.nextDouble() * 2 + 0.3,
        isGold: _rng.nextBool(),
        phase: _rng.nextDouble(),
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = ((p.baseY - progress * p.speed + p.phase) % 1.0) * size.height;
      final paint = Paint()
        ..color = (p.isGold ? NajmaColors.gold : NajmaColors.textPrimary)
            .withOpacity((0.1 + p.size * 0.15).clamp(0.0, 0.7));
      canvas.drawCircle(Offset(p.x * size.width, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x, baseY, speed, size, phase;
  final bool isGold;
  const _Particle({
    required this.x,
    required this.baseY,
    required this.speed,
    required this.size,
    required this.isGold,
    required this.phase,
  });
}

""",


}


# ملفات تُستبدل دائماً حتى لو موجودة
FORCE_OVERWRITE = {
    "lib/features/auth/presentation/screens/otp_screen.dart",
    "lib/core/app/najma_app.dart",
    "lib/main.dart",
    "lib/core/router/app_router.dart",
    "lib/features/language/presentation/screens/language_screen.dart",
    "lib/features/role_select/presentation/screens/role_select_screen.dart",
    "lib/features/splash/presentation/screens/splash_screen.dart",
    "lib/features/home/presentation/screens/celebrant_home_screen.dart",
    "lib/features/artist_profile/presentation/screens/artist_profile_screen.dart",
    "lib/features/artist_dashboard/presentation/screens/artist_dashboard_screen.dart",
}

# ── الإنشاء ────────────────────────────────────────────────────────
def create_files(base: str):
    created = 0
    skipped = 0
    for rel_path, file_content in FILES.items():
        full_path = os.path.join(base, rel_path.replace("/", os.sep))
        if os.path.exists(full_path) and rel_path not in FORCE_OVERWRITE:
            print(f"  ⏭  موجود مسبقاً: {rel_path}")
            skipped += 1
            continue
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        with open(full_path, "w", encoding="utf-8") as f:
            f.write(file_content)
        print(f"  ✅ أُنشئ: {rel_path}")
        created += 1

    print(f"\n{'='*50}")
    print(f"✅ أُنشئ:         {created} ملف")
    print(f"⏭  موجود مسبقاً: {skipped} ملف")
    print(f"{'='*50}")
    print("\nالخطوة التالية:")
    print("  flutter pub get")
    print("  flutter run")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="نجمة Flutter scaffold")
    parser.add_argument("--path", default=DEFAULT_PATH, help="مسار مشروع Flutter")
    args = parser.parse_args()

    base = args.path
    if not os.path.isdir(base):
        print(f"❌ المسار غير موجود: {base}")
        print(f'   استخدم: python najma_setup.py --path "مسار المشروع"')
        exit(1)

    print(f"\n🚀 نجمة Flutter Scaffold")
    print(f"📁 المسار: {base}\n")
    create_files(base)