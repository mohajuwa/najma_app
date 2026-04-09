import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/najma_top_bar.dart';
import '../../../../core/widgets/najma_shimmer.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId; // هذا هو track_token
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Map<String, dynamic>? _order;
  bool   _loading = true;
  String? _error;
  Timer? _refreshTimer;

  static const _steps = [
    'pending', 'paid', 'accepted', 'performing', 'delivered', 'completed',
  ];

  static const _stepLabels = {
    'pending'   : 'قيد الانتظار',
    'paid'      : 'تم الدفع',
    'accepted'  : 'قبل الفنان',
    'performing': 'جاري التنفيذ',
    'delivered' : 'تم التسليم',
    'completed' : 'مكتمل',
    'rejected'  : 'مرفوض',
    'refunded'  : 'مسترجع',
  };

  @override
  void initState() {
    super.initState();
    _load();
    // Auto-refresh كل 15 ثانية للطلبات الحية
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_order != null) {
        final status  = _order!['status'] as String? ?? '';
        final isLive  = ['pending', 'paid', 'accepted', 'performing'].contains(status);
        if (isLive) _load(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() { _loading = true; _error = null; });
    try {
      // ← URL مُصحَّح: orders/track/{token}
      final res = await ApiClient.dio.get('orders/track/${widget.orderId}');
      if (mounted) setState(() {
        _order   = res.data['data'] as Map<String, dynamic>;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _error   = 'تعذّر تحميل الطلب';
        _loading = false;
      });
    }
  }

  void _copyToken() {
    Clipboard.setData(ClipboardData(text: widget.orderId));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('تم نسخ رمز التتبع'),
      backgroundColor: NajmaColors.surface,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NajmaColors.black,
        appBar: NajmaTopBar(
          title: 'تتبع الطلب',
          actions: [
            IconButton(
              onPressed: _copyToken,
              icon: const Icon(Icons.copy_rounded, color: NajmaColors.gold, size: 20),
            ),
          ],
        ),
        body: _loading
            ? _buildSkeleton()
            : _error != null
                ? _buildError()
                : RefreshIndicator(
                    color: NajmaColors.gold,
                    backgroundColor: NajmaColors.surface,
                    onRefresh: _load,
                    child: _buildContent(),
                  ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NajmaShimmer(height: 56),
        const SizedBox(height: 24),
        NajmaShimmer(height: 200),
        const SizedBox(height: 24),
        NajmaShimmer(height: 120),
      ]),
    );
  }

  Widget _buildError() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, color: NajmaColors.goldDim, size: 48),
      const SizedBox(height: 16),
      Text(_error!, style: NajmaTextStyles.body(color: NajmaColors.textDim)),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: _load,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: NajmaColors.gold.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('إعادة المحاولة', style: NajmaTextStyles.gold()),
        ),
      ),
    ]));
  }

  Widget _buildContent() {
    final order      = _order!;
    final status     = order['status'] as String? ?? 'pending';
    final stepIdx    = _steps.indexOf(status);
    final isTerminal = ['completed', 'rejected', 'refunded'].contains(status);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _TrackTokenCard(token: widget.orderId),
        const SizedBox(height: 20),
        _CurrentStatusBadge(status: status, label: _stepLabels[status] ?? status),
        if (!isTerminal) ...[
          const SizedBox(height: 20),
          Text('مراحل الطلب', style: NajmaTextStyles.heading(size: 15)),
          const SizedBox(height: 16),
          _OrderStepper(steps: _steps, currentIdx: stepIdx, labels: _stepLabels),
        ],
        const SizedBox(height: 24),
        _DetailSection(order: order),
        // ── زر المحتوى المُسلَّم ─────────────────────────────────
        if (['delivered', 'completed'].contains(status)) ...[
          const SizedBox(height: 20),
          _DeliverablesBtn(order: order),
        ],
      ],
    );
  }
}

// ── زر محتوى مُسلَّم ──────────────────────────────────────────────
class _DeliverablesBtn extends StatelessWidget {
  final Map<String, dynamic> order;
  const _DeliverablesBtn({required this.order});

  @override
  Widget build(BuildContext context) {
    final orderId    = order['id'] as int? ?? 0;
    final artistName = order['artist']?['name_ar'] ?? 'الفنان';
    final isArtist   = LocalStorage.getRole() == 'artist';
    final route      = isArtist
        ? '/artist-dashboard/order-deliverables/$orderId'
        : '/home/order-deliverables/$orderId';

    return GestureDetector(
      onTap: () => context.push(
        '$route?title=${Uri.encodeComponent(isArtist ? "تسليم الخدمة" : "محتوى من $artistName")}'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              NajmaColors.gold.withOpacity(0.08),
              NajmaColors.gold.withOpacity(0.03),
            ],
          ),
          border: Border.all(
              color: NajmaColors.gold.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: NajmaColors.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.music_note_rounded,
                color: NajmaColors.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArtist ? 'رفع محتوى للعميل' : 'المحتوى المُسلَّم 🎵',
                  style: NajmaTextStyles.heading(size: 14),
                ),
                Text(
                  isArtist
                      ? 'شارك فيديو أو تسجيل صوتي من الحفلة'
                      : 'فيديوهات وتسجيلات من الفنان',
                  style: NajmaTextStyles.caption(
                      size: 11, color: NajmaColors.textSecond),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: NajmaColors.gold, size: 20),
        ]),
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────

class _TrackTokenCard extends StatelessWidget {
  final String token;
  const _TrackTokenCard({required this.token});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(color: NajmaColors.goldDim.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        const Icon(Icons.qr_code_rounded, color: NajmaColors.gold, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(
          'رمز التتبع: $token',
          style: NajmaTextStyles.caption(size: 11, color: NajmaColors.textSecond),
          overflow: TextOverflow.ellipsis,
        )),
      ]),
    );
  }
}

class _CurrentStatusBadge extends StatelessWidget {
  final String status, label;
  const _CurrentStatusBadge({required this.status, required this.label});

  Color get _color => switch (status) {
    'completed'  => const Color(0xFF4CAF50),
    'rejected'   => NajmaColors.error,
    'refunded'   => NajmaColors.error,
    'performing' => NajmaColors.goldBright,
    _            => NajmaColors.gold,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.08),
        border: Border.all(color: _color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(children: [
        Text('الحالة الحالية',
            style: NajmaTextStyles.caption(size: 11, color: NajmaColors.textSecond)),
        const SizedBox(height: 6),
        Text(label, style: NajmaTextStyles.heading(size: 18, color: _color)),
      ]),
    );
  }
}

class _OrderStepper extends StatelessWidget {
  final List<String> steps;
  final int currentIdx;
  final Map<String, String> labels;
  const _OrderStepper({required this.steps, required this.currentIdx, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final done   = currentIdx >= i;
        final active = currentIdx == i;
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? NajmaColors.gold : NajmaColors.surface,
                border: Border.all(
                  color: done ? NajmaColors.gold : NajmaColors.goldDim.withOpacity(0.3),
                ),
              ),
              child: done
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.black)
                  : null,
            ),
            if (i < steps.length - 1)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 2, height: 32,
                color: done
                    ? NajmaColors.gold.withOpacity(0.4)
                    : NajmaColors.goldDim.withOpacity(0.15),
              ),
          ]),
          const SizedBox(width: 14),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              labels[steps[i]] ?? steps[i],
              style: NajmaTextStyles.body(
                size: active ? 15 : 13,
                color: active
                    ? NajmaColors.goldBright
                    : done ? NajmaColors.textSecond : NajmaColors.textDim,
              ),
            ),
          ),
        ]);
      }),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final Map<String, dynamic> order;
  const _DetailSection({required this.order});

  static String _timingLabel(dynamic t) => switch (t) {
    'before' => 'قبل المناسبة',
    'during' => 'أثناء المناسبة',
    'after'  => 'بعد المناسبة',
    _        => t?.toString() ?? '—',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(color: NajmaColors.goldDim.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(children: [
        _InfoRow('الفنان',   order['artist']?['name_ar'] ?? '—'),
        _InfoRow('الخدمة',  order['service']?['name_ar'] ?? '—'),
        _InfoRow('المحتفل', order['fan_name'] ?? '—'),
        _InfoRow('التوقيت', _timingLabel(order['timing'])),
        if ((order['message'] ?? '').toString().isNotEmpty)
          _InfoRow('الرسالة', order['message']),
        const SizedBox(height: 4),
        Divider(color: NajmaColors.goldDim.withOpacity(0.2), height: 1),
        const SizedBox(height: 4),
        _InfoRow('المبلغ', '${order['amount']} ر.س',
            valueColor: NajmaColors.goldBright),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _InfoRow(this.label, this.value, {this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: NajmaTextStyles.body(size: 13, color: NajmaColors.textSecond)),
        Flexible(child: Text(
          value,
          style: NajmaTextStyles.body(size: 13, color: valueColor ?? NajmaColors.textPrimary),
          textAlign: TextAlign.end,
        )),
      ]),
    );
  }
}
