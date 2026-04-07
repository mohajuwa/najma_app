
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/najma_top_bar.dart';
import '../../../../core/network/api_client.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Map<String, dynamic>? _order;
  bool  _loading = true;
  String? _error;

  final _steps = const [
    'pending', 'paid', 'accepted', 'performing', 'delivered', 'completed',
  ];

  final _stepLabels = const {
    'pending':    'قيد الانتظار',
    'paid':       'تم الدفع',
    'accepted':   'قبل الفنان',
    'performing': 'جاري التنفيذ',
    'delivered':  'تم التسليم',
    'completed':  'مكتمل',
    'rejected':   'مرفوض',
    'refunded':   'مسترجع',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient.dio.get('orders/track/${widget.orderId}');
      setState(() { _order = res.data['data'] as Map<String, dynamic>; });
    } catch (e) {
      setState(() => _error = 'تعذّر تحميل الطلب');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
            if (_order != null)
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _order!['track_token']));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ رمز التتبع')),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.copy, color: NajmaColors.gold, size: 20),
                ),
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: NajmaColors.gold))
            : _error != null
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_error!, style: NajmaTextStyles.body(color: NajmaColors.textDim)),
                    const SizedBox(height: 16),
                    GestureDetector(onTap: _load,
                        child: Text('إعادة المحاولة', style: NajmaTextStyles.gold())),
                  ]))
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final order   = _order!;
    final status  = order['status'] as String;
    final stepIdx = _steps.indexOf(status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Track token
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NajmaColors.surface,
            border: Border.all(color: NajmaColors.goldDim.withOpacity(0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.qr_code, color: NajmaColors.gold, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'رمز التتبع: ${order['track_token']}',
              style: NajmaTextStyles.caption(size: 11, color: NajmaColors.textSecond),
            )),
          ]),
        ),
        const SizedBox(height: 24),

        // ── Status stepper
        Text('حالة الطلب', style: NajmaTextStyles.heading(size: 15)),
        const SizedBox(height: 16),
        ...List.generate(_steps.length, (i) {
          final done   = stepIdx >= i;
          final active = stepIdx == i;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? NajmaColors.gold : NajmaColors.surface,
                  border: Border.all(
                    color: done ? NajmaColors.gold : NajmaColors.goldDim.withOpacity(0.3),
                  ),
                ),
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : null,
              ),
              if (i < _steps.length - 1)
                Container(width: 2, height: 32,
                    color: done ? NajmaColors.gold.withOpacity(0.4) : NajmaColors.surface),
            ]),
            const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _stepLabels[_steps[i]] ?? _steps[i],
                style: NajmaTextStyles.body(
                  size: active ? 15 : 13,
                  color: active ? NajmaColors.goldBright
                      : done ? NajmaColors.textSecond
                      : NajmaColors.textDim,
                ),
              ),
            ),
          ]);
        }),

        const SizedBox(height: 28),

        // ── Order details
        _DetailRow('الفنان',    order['artist']?['name_ar'] ?? '—'),
        _DetailRow('الخدمة',   order['service']?['name_ar'] ?? '—'),
        _DetailRow('المحتفل',  order['fan_name'] ?? '—'),
        _DetailRow('التوقيت',  _timingLabel(order['timing'])),
        if (order['message'] != null && order['message'].toString().isNotEmpty)
          _DetailRow('الرسالة', order['message']),
        const SizedBox(height: 8),
        Container(height: 0.5, color: NajmaColors.goldDim.withOpacity(0.2)),
        const SizedBox(height: 8),
        _DetailRow('المبلغ',
            '${order['amount']} ر.س',
            valueColor: NajmaColors.goldBright),
      ]),
    );
  }

  String _timingLabel(String? t) {
    switch (t) {
      case 'before': return 'قبل المناسبة';
      case 'during': return 'أثناء المناسبة';
      case 'after':  return 'بعد المناسبة';
      default:       return t ?? '—';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: NajmaTextStyles.body(size: 13, color: NajmaColors.textSecond)),
        Text(value,  style: NajmaTextStyles.body(size: 13,
            color: valueColor ?? NajmaColors.textPrimary)),
      ]),
    );
  }
}
