import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_notifier.dart';
import '../../../../core/widgets/najma_shimmer.dart';
import '../../domain/entities/artist_service_entity.dart';
import '../bloc/artist_services_bloc.dart';

// أنواع الخدمات
const _serviceTypes = [
  ('normal_greeting',  'تهنئة عادية',   '🎤'),
  ('special_greeting', 'تهنئة مميزة',   '🌟'),
  ('vip_greeting',     'تهنئة VIP',      '👑'),
  ('setlist',          'قائمة أغاني',    '🎵'),
  ('booking',          'حجز خاص',        '📅'),
];

String _typeLabel(String type) =>
    _serviceTypes.firstWhere((t) => t.$1 == type, orElse: () => (type, type, '🎭')).$2;
String _typeEmoji(String type) =>
    _serviceTypes.firstWhere((t) => t.$1 == type, orElse: () => (type, type, '🎭')).$3;

class ArtistServicesScreen extends StatelessWidget {
  const ArtistServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArtistServicesBloc()..add(LoadServicesEvent()),
      child: const _ServicesBody(),
    );
  }
}

class _ServicesBody extends StatelessWidget {
  const _ServicesBody();

  @override
  Widget build(BuildContext context) {
    final s   = AppStrings.of(context);
    final dir = LocaleNotifier.instance.textDirection;

    return BlocListener<ArtistServicesBloc, ArtistServicesState>(
      listener: (ctx, state) {
        if (state is ArtistServiceActionSuccess) {
          _snack(ctx, state.message, NajmaColors.success);
        }
        if (state is ArtistServiceActionError) {
          _snack(ctx, state.message, NajmaColors.error);
        }
        if (state is ArtistServicesError) {
          _snack(ctx, state.message, NajmaColors.error);
        }
      },
      child: Directionality(
        textDirection: dir,
        child: Scaffold(
          backgroundColor: NajmaColors.black,
          body: SafeArea(
            child: Column(children: [
              _Header(s: s),
              Expanded(
                child: BlocBuilder<ArtistServicesBloc, ArtistServicesState>(
                  // تجاهل states الإجراءات — الـ Builder يبني فقط عند تغيير القائمة
                  buildWhen: (prev, curr) =>
                      curr is ArtistServicesLoading  ||
                      curr is ArtistServicesLoaded   ||
                      curr is ArtistServicesSaving   ||
                      curr is ArtistServicesError,
                  builder: (ctx, state) {
                    if (state is ArtistServicesLoading) return _Skeleton();
                    if (state is ArtistServicesError) {
                      return _ErrorView(message: state.message,
                          onRetry: () => ctx.read<ArtistServicesBloc>().add(LoadServicesEvent()));
                    }
                    final services = _extractList(state);
                    final isSaving = state is ArtistServicesSaving;
                    return _ServicesList(
                        services: services,
                        isSaving: isSaving,
                        s: s);
                  },
                ),
              ),
            ]),
          ),
          floatingActionButton: _AddFab(s: s),
        ),
      ),
    );
  }

  List<ArtistServiceEntity> _extractList(ArtistServicesState state) {
    if (state is ArtistServicesLoaded) return state.services;
    if (state is ArtistServicesSaving)  return state.services;
    return [];
  }

  void _snack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg, style: NajmaTextStyles.body(size: 13, color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ));
  }
}

// ─────────────────────────────── Header ──────────────────────────
class _Header extends StatelessWidget {
  final AppStrings s;
  const _Header({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(
            color: NajmaColors.goldDim.withOpacity(0.2))),
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: NajmaColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: NajmaColors.goldDim.withOpacity(0.2)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: NajmaColors.gold, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.myServices, style: NajmaTextStyles.heading(size: 17)),
          Text('MY SERVICES', style: NajmaTextStyles.label()),
        ]),
        const Spacer(),
        BlocBuilder<ArtistServicesBloc, ArtistServicesState>(
          buildWhen: (_, curr) =>
              curr is ArtistServicesSaving || curr is ArtistServicesLoaded,
          builder: (_, state) => state is ArtistServicesSaving
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: NajmaColors.gold, strokeWidth: 2))
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }
}

// ─────────────────────────────── List ────────────────────────────
class _ServicesList extends StatelessWidget {
  final List<ArtistServiceEntity> services;
  final bool isSaving;
  final AppStrings s;
  const _ServicesList({required this.services, required this.isSaving, required this.s});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(s.noServicesAdded,
              style: NajmaTextStyles.body(color: NajmaColors.textDim)),
          const SizedBox(height: 8),
          Text(s.isAr ? 'اضغط + لإضافة أول خدمة' : 'Tap + to add your first service',
              style: NajmaTextStyles.caption(color: NajmaColors.textDim)),
        ],
      ));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _ServiceCard(
        service:  services[i],
        isSaving: isSaving,
        s:        s,
      ),
    );
  }
}

// ─────────────────────────────── Card ────────────────────────────
class _ServiceCard extends StatelessWidget {
  final ArtistServiceEntity service;
  final bool isSaving;
  final AppStrings s;
  const _ServiceCard({required this.service, required this.isSaving, required this.s});

  @override
  Widget build(BuildContext context) {
    final active = service.isActive;

    return Container(
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(
          color: active
              ? NajmaColors.goldDim.withOpacity(0.25)
              : NajmaColors.surface2,
          width: active ? 1 : 0.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Opacity(
        opacity: active ? 1.0 : 0.55,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // إيموجي + نوع
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: active
                      ? NajmaColors.gold.withOpacity(0.1)
                      : NajmaColors.surface2,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: active
                          ? NajmaColors.goldDim.withOpacity(0.3)
                          : NajmaColors.surface2),
                ),
                child: Center(child: Text(_typeEmoji(service.type),
                    style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),

              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.nameAr,
                      style: NajmaTextStyles.body(size: 14),
                      overflow: TextOverflow.ellipsis),
                  Text(_typeLabel(service.type),
                      style: NajmaTextStyles.caption(
                          size: 11, color: NajmaColors.textSecond)),
                ],
              )),

              // السعر
              Text('${service.price.toStringAsFixed(0)} ${s.sar}',
                  style: NajmaTextStyles.body(
                      size: 15, color: NajmaColors.goldBright)
                      .copyWith(fontWeight: FontWeight.w700)),
            ]),

            if (service.descriptionAr != null && service.descriptionAr!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(service.descriptionAr!,
                  style: NajmaTextStyles.caption(
                      size: 12, color: NajmaColors.textSecond),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],

            const SizedBox(height: 12),
            const Divider(color: Color(0xFF1E1E1E), height: 1),
            const SizedBox(height: 10),

            // الأزرار
            Row(children: [
              // تفعيل/تعطيل
              GestureDetector(
                onTap: isSaving ? null : () {
                  HapticFeedback.lightImpact();
                  context.read<ArtistServicesBloc>()
                      .add(ToggleServiceEvent(service.id, !active));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? NajmaColors.success.withOpacity(0.08)
                        : NajmaColors.surface2,
                    border: Border.all(
                        color: active
                            ? NajmaColors.success.withOpacity(0.35)
                            : NajmaColors.goldDim.withOpacity(0.15)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: active ? NajmaColors.success : NajmaColors.textDim,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      active
                          ? (s.isAr ? 'نشطة' : 'Active')
                          : (s.isAr ? 'معطّلة' : 'Inactive'),
                      style: NajmaTextStyles.caption(
                          size: 11,
                          color: active ? NajmaColors.success : NajmaColors.textDim)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ]),
                ),
              ),

              const Spacer(),

              // زر التعديل
              GestureDetector(
                onTap: isSaving ? null : () =>
                    _showSheet(context, service: service),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: NajmaColors.gold.withOpacity(0.07),
                    border: Border.all(
                        color: NajmaColors.goldDim.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.edit_outlined,
                        color: NajmaColors.gold, size: 14),
                    const SizedBox(width: 4),
                    Text(s.edit,
                        style: NajmaTextStyles.caption(
                            size: 12, color: NajmaColors.gold)),
                  ]),
                ),
              ),

              const SizedBox(width: 8),

              // زر الحذف
              GestureDetector(
                onTap: isSaving ? null : () =>
                    _confirmDelete(context, service, s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: NajmaColors.error.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: NajmaColors.error, size: 16),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, ArtistServiceEntity svc, AppStrings s) {
    showDialog(
      context: ctx,
      builder: (_) => Directionality(
        textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: NajmaColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(s.isAr ? 'حذف الخدمة' : 'Delete Service',
              style: NajmaTextStyles.heading(size: 16)),
          content: Text(
            s.isAr
                ? 'هل أنت متأكد من حذف "${svc.nameAr}"؟'
                : 'Are you sure you want to delete "${svc.nameAr}"?',
            style: NajmaTextStyles.body(size: 13, color: NajmaColors.textSecond),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel, style: NajmaTextStyles.gold()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ctx.read<ArtistServicesBloc>().add(DeleteServiceEvent(svc.id));
              },
              child: Text(s.delete,
                  style: NajmaTextStyles.body(size: 14, color: NajmaColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────── FAB ─────────────────────────────
class _AddFab extends StatelessWidget {
  final AppStrings s;
  const _AddFab({required this.s});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSheet(context),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [NajmaColors.goldDim, NajmaColors.gold]),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: NajmaColors.gold.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.add, color: NajmaColors.black, size: 20),
          const SizedBox(width: 6),
          Text(s.addService,
              style: NajmaTextStyles.body(size: 14, color: NajmaColors.black)
                  .copyWith(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────── Error ───────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, color: NajmaColors.textDim, size: 44),
        const SizedBox(height: 12),
        Text(message, style: NajmaTextStyles.body(color: NajmaColors.textDim)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: NajmaColors.gold.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(AppStrings.of(context).retry,
                style: NajmaTextStyles.gold(size: 13)),
          ),
        ),
      ],
    ));
  }
}

// ─────────────────────────────── Skeleton ────────────────────────
class _Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => NajmaShimmer(height: 110),
    );
  }
}

// ─────────────────────────────── Bottom Sheet: Add/Edit ──────────
void _showSheet(BuildContext context, {ArtistServiceEntity? service}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<ArtistServicesBloc>(),
      child: _ServiceSheet(service: service),
    ),
  );
}

class _ServiceSheet extends StatefulWidget {
  final ArtistServiceEntity? service;
  const _ServiceSheet({this.service});

  @override
  State<_ServiceSheet> createState() => _ServiceSheetState();
}

class _ServiceSheetState extends State<_ServiceSheet> {
  final _nameArCtrl = TextEditingController();
  final _nameEnCtrl = TextEditingController();
  final _priceCtrl  = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _formKey    = GlobalKey<FormState>();
  String _selectedType = _serviceTypes.first.$1;

  bool get _isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final svc = widget.service!;
      _nameArCtrl.text  = svc.nameAr;
      _nameEnCtrl.text  = svc.nameEn ?? '';
      _priceCtrl.text   = svc.price.toStringAsFixed(0);
      _descCtrl.text    = svc.descriptionAr ?? '';
      _selectedType     = svc.type;
    }
  }

  @override
  void dispose() {
    _nameArCtrl.dispose();
    _nameEnCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final nameAr = _nameArCtrl.text.trim();
    final nameEn = _nameEnCtrl.text.trim().isEmpty ? null : _nameEnCtrl.text.trim();
    final price  = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final desc   = _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim();

    if (_isEdit) {
      context.read<ArtistServicesBloc>().add(UpdateServiceEvent(
        id:            widget.service!.id,
        nameAr:        nameAr,
        nameEn:        nameEn,
        price:         price,
        descriptionAr: desc,
      ));
    } else {
      context.read<ArtistServicesBloc>().add(AddServiceEvent(
        type:          _selectedType,
        nameAr:        nameAr,
        nameEn:        nameEn,
        price:         price,
        descriptionAr: desc,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s   = AppStrings.of(context);
    final pad = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + pad),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.2)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Handle
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: NajmaColors.goldDim.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              )),
              const SizedBox(height: 20),

              // العنوان
              Row(children: [
                Container(width: 3, height: 18, color: NajmaColors.gold),
                const SizedBox(width: 10),
                Text(
                  _isEdit
                      ? (s.isAr ? 'تعديل الخدمة' : 'Edit Service')
                      : (s.isAr ? 'إضافة خدمة جديدة' : 'Add New Service'),
                  style: NajmaTextStyles.heading(size: 16),
                ),
              ]),
              const SizedBox(height: 20),

              // نوع الخدمة (فقط عند الإضافة)
              if (!_isEdit) ...[
                _Label(s.isAr ? 'نوع الخدمة *' : 'Service Type *'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 46,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _serviceTypes.length,
                    itemBuilder: (_, i) {
                      final t      = _serviceTypes[i];
                      final active = _selectedType == t.$1;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedType = t.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: active
                                ? NajmaColors.gold.withOpacity(0.12)
                                : NajmaColors.surface2,
                            border: Border.all(
                              color: active
                                  ? NajmaColors.gold
                                  : NajmaColors.goldDim.withOpacity(0.2),
                              width: active ? 1.5 : 0.8,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(t.$3, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(t.$2,
                                  style: NajmaTextStyles.caption(
                                    size: 12,
                                    color: active
                                        ? NajmaColors.gold
                                        : NajmaColors.textSecond,
                                  ).copyWith(
                                      fontWeight: active
                                          ? FontWeight.w700
                                          : FontWeight.w400)),
                            ],
                          )),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // اسم الخدمة بالعربي
              _Label(s.isAr ? 'اسم الخدمة بالعربي *' : 'Service Name (Arabic) *'),
              const SizedBox(height: 6),
              _Field(
                ctrl:      _nameArCtrl,
                hint:      s.isAr ? 'مثال: تهنئة عيد ميلاد...' : 'e.g. Birthday greeting...',
                dir:       TextDirection.rtl,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? (s.isAr ? 'أدخل اسم الخدمة' : 'Enter service name') : null,
              ),
              const SizedBox(height: 12),

              // اسم الخدمة بالإنجليزي (اختياري)
              _Label(s.isAr ? 'اسم الخدمة بالإنجليزي (اختياري)' : 'Service Name (English, optional)'),
              const SizedBox(height: 6),
              _Field(
                ctrl: _nameEnCtrl,
                hint: 'e.g. Birthday greeting...',
                dir:  TextDirection.ltr,
              ),
              const SizedBox(height: 12),

              // السعر
              _Label(s.isAr ? 'السعر (ر.س) *' : 'Price (SAR) *'),
              const SizedBox(height: 6),
              _Field(
                ctrl:          _priceCtrl,
                hint:          '150',
                keyboardType:  TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return s.isAr ? 'أدخل السعر' : 'Enter price';
                  }
                  final n = double.tryParse(v);
                  if (n == null || n < 1) {
                    return s.isAr ? 'السعر يجب أن يكون أكبر من 0' : 'Price must be > 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // الوصف
              _Label(s.isAr ? 'وصف مختصر (اختياري)' : 'Short description (optional)'),
              const SizedBox(height: 6),
              _Field(
                ctrl:     _descCtrl,
                hint:     s.isAr ? 'صِف ما تقدمه في هذه الخدمة...' : 'Describe what you offer...',
                dir:      TextDirection.rtl,
                maxLines: 3,
              ),
              const SizedBox(height: 28),

              // زر الحفظ
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [NajmaColors.goldDim, NajmaColors.gold]),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: NajmaColors.gold.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(child: Text(
                    s.saveChanges,
                    style: NajmaTextStyles.body(
                        size: 15, color: NajmaColors.black)
                        .copyWith(fontWeight: FontWeight.w800),
                  )),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────── Helpers ─────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: NajmaTextStyles.caption(size: 11, color: NajmaColors.textSecond),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final TextDirection dir;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl,
    required this.hint,
    this.dir          = TextDirection.rtl,
    this.maxLines     = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:      ctrl,
      textDirection:   dir,
      maxLines:        maxLines,
      keyboardType:    keyboardType,
      inputFormatters: inputFormatters,
      validator:       validator,
      style:           NajmaTextStyles.body(size: 14),
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: NajmaTextStyles.caption(size: 13, color: NajmaColors.textDim),
        filled:    true,
        fillColor: NajmaColors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border:         OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: NajmaColors.goldDim.withOpacity(0.25))),
        enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: NajmaColors.goldDim.withOpacity(0.2))),
        focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: NajmaColors.gold, width: 1.5)),
        errorBorder:    OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: NajmaColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: NajmaColors.error, width: 1.5)),
      ),
    );
  }
}
