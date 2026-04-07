
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/najma_button.dart';
import '../../../../core/widgets/najma_top_bar.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_notifier.dart';
import '../../../../core/network/api_client.dart';

class CheckoutScreen extends StatefulWidget {
  final int    serviceId;
  final String serviceName;
  final double servicePrice;
  final String artistName;

  const CheckoutScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.artistName,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameCtrl    = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _timing     = 'before';
  bool   _loading    = false;
  String? _error;

  final _timings = const [
    {'val': 'before', 'ar': 'قبل المناسبة',  'en': 'Before'},
    {'val': 'during', 'ar': 'أثناء المناسبة', 'en': 'During'},
    {'val': 'after',  'ar': 'بعد المناسبة',  'en': 'After'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'أدخل اسم المحتفل');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient.dio.post('orders', data: {
        'service_id': widget.serviceId,
        'fan_name':   _nameCtrl.text.trim(),
        'message':    _messageCtrl.text.trim(),
        'timing':     _timing,
      });
      if (mounted) {
        final order = res.data['data'];
        context.go('/home/track/${order['track_token']}');
      }
    } catch (e) {
      setState(() => _error = 'حدث خطأ، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s   = AppStrings.of(context);
    final dir = LocaleNotifier.instance.textDirection;

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        backgroundColor: NajmaColors.black,
        appBar: NajmaTopBar(title: s.createOrder),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── ملخص الطلب
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NajmaColors.surface,
                border: Border.all(color: NajmaColors.goldDim.withOpacity(0.3)),
              ),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(widget.artistName, style: NajmaTextStyles.heading(size: 16)),
                  Text(widget.serviceName, style: NajmaTextStyles.gold()),
                ]),
                const SizedBox(height: 12),
                Container(height: 0.5, color: NajmaColors.goldDim.withOpacity(0.3)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(s.total, style: NajmaTextStyles.body(color: NajmaColors.textSecond)),
                  Text('${widget.servicePrice.toStringAsFixed(0)} ر.س',
                      style: NajmaTextStyles.heading(size: 18, color: NajmaColors.goldBright)),
                ]),
              ]),
            ),
            const SizedBox(height: 28),

            // ── اسم المحتفل
            _FieldLabel('اسم المحتفل'),
            const SizedBox(height: 8),
            _buildInput(_nameCtrl, 'مثال: أحمد محمد'),
            const SizedBox(height: 20),

            // ── توقيت التهنئة
            _FieldLabel('توقيت التهنئة'),
            const SizedBox(height: 10),
            Row(children: _timings.map((t) {
              final active = _timing == t['val'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _timing = t['val']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? NajmaColors.gold.withOpacity(0.12) : NajmaColors.surface,
                      border: Border.all(
                        color: active ? NajmaColors.gold : NajmaColors.goldDim.withOpacity(0.2),
                        width: active ? 1.2 : 0.5,
                      ),
                    ),
                    child: Center(child: Text(t['ar']!,
                        style: NajmaTextStyles.caption(
                            size: 11,
                            color: active ? NajmaColors.gold : NajmaColors.textSecond))),
                  ),
                ),
              );
            }).toList()),
            const SizedBox(height: 20),

            // ── رسالة
            _FieldLabel('رسالة للفنان (اختياري)'),
            const SizedBox(height: 8),
            _buildInput(_messageCtrl, 'اكتب ما تريد أن يقوله الفنان...', maxLines: 4),
            const SizedBox(height: 12),

            // ── خطأ
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NajmaColors.error.withOpacity(0.1),
                  border: Border.all(color: NajmaColors.error.withOpacity(0.4)),
                ),
                child: Text(_error!, style: NajmaTextStyles.body(size: 13, color: NajmaColors.error)),
              ),

            const SizedBox(height: 32),
            NajmaButton(
              label: 'تأكيد الطلب — ${widget.servicePrice.toStringAsFixed(0)} ر.س',
              isLoading: _loading,
              onTap: _submit,
            ),
            const SizedBox(height: 16),
            Center(child: Text(
              '* سيتم التواصل معك لإتمام الدفع',
              style: NajmaTextStyles.caption(size: 11),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(color: NajmaColors.goldDim.withOpacity(0.3)),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: NajmaTextStyles.body(size: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          hintText: hint,
          hintStyle: NajmaTextStyles.body(size: 13, color: NajmaColors.textDim),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: NajmaTextStyles.caption(size: 12, color: NajmaColors.textSecond));
}
