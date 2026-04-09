import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/najma_button.dart';
import '../../../../core/widgets/najma_top_bar.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_notifier.dart';
import '../bloc/checkout_bloc.dart';

class CheckoutScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckoutBloc(),
      child: _CheckoutBody(
        serviceId   : serviceId,
        serviceName : serviceName,
        servicePrice: servicePrice,
        artistName  : artistName,
      ),
    );
  }
}

class _CheckoutBody extends StatefulWidget {
  final int    serviceId;
  final String serviceName;
  final double servicePrice;
  final String artistName;

  const _CheckoutBody({
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.artistName,
  });

  @override
  State<_CheckoutBody> createState() => _CheckoutBodyState();
}

class _CheckoutBodyState extends State<_CheckoutBody> {
  final _nameCtrl    = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _formKey     = GlobalKey<FormState>();
  String _timing     = 'before';

  static const _timings = [
    ('before', 'قبل المناسبة',  'Before'),
    ('during', 'أثناء المناسبة', 'During'),
    ('after',  'بعد المناسبة',  'After'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CheckoutBloc>().add(SubmitOrderEvent(
      serviceId: widget.serviceId,
      fanName  : _nameCtrl.text.trim(),
      message  : _messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim(),
      timing   : _timing,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dir = LocaleNotifier.instance.textDirection;

    return BlocListener<CheckoutBloc, CheckoutState>(
      listener: (ctx, state) {
        if (state is CheckoutSuccess) {
          ctx.go('/home/track/${state.trackToken}');
        }
        if (state is CheckoutError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(state.message, style: NajmaTextStyles.body(size: 13)),
            backgroundColor: NajmaColors.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));
        }
      },
      child: Directionality(
        textDirection: dir,
        child: Scaffold(
          backgroundColor: NajmaColors.black,
          appBar: NajmaTopBar(title: AppStrings.of(context).createOrder),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              children: [
                // ── ملخص الطلب
                _OrderSummaryCard(
                  artistName  : widget.artistName,
                  serviceName : widget.serviceName,
                  servicePrice: widget.servicePrice,
                ),
                const SizedBox(height: 28),

                // ── اسم المحتفل
                _FieldLabel('اسم المحتفل *'),
                const SizedBox(height: 8),
                _NajmaFormField(
                  controller: _nameCtrl,
                  hint: 'مثال: أحمد محمد',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'أدخل اسم المحتفل' : null,
                ),
                const SizedBox(height: 20),

                // ── توقيت
                _FieldLabel('توقيت التهنئة'),
                const SizedBox(height: 10),
                _TimingSelector(
                  selected: _timing,
                  timings : _timings,
                  onSelect: (v) => setState(() => _timing = v),
                ),
                const SizedBox(height: 20),

                // ── رسالة
                _FieldLabel('رسالة للفنان (اختياري)'),
                const SizedBox(height: 8),
                _NajmaFormField(
                  controller: _messageCtrl,
                  hint: 'اكتب ما تريد أن يقوله الفنان...',
                  maxLines: 4,
                ),
                const SizedBox(height: 32),

                // ── زر الإرسال
                BlocBuilder<CheckoutBloc, CheckoutState>(
                  builder: (_, state) => NajmaButton(
                    label: 'تأكيد الطلب — ${widget.servicePrice.toStringAsFixed(0)} ر.س',
                    isLoading: state is CheckoutLoading,
                    onTap: _submit,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '* سيتم التواصل معك لإتمام الدفع',
                    style: NajmaTextStyles.caption(size: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets مساعدة ──────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  final String artistName, serviceName;
  final double servicePrice;
  const _OrderSummaryCard({
    required this.artistName,
    required this.serviceName,
    required this.servicePrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(color: NajmaColors.goldDim.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(artistName,  style: NajmaTextStyles.heading(size: 15)),
          Text(serviceName, style: NajmaTextStyles.gold(size: 13)),
        ]),
        const SizedBox(height: 12),
        Divider(color: NajmaColors.goldDim.withOpacity(0.3), height: 1),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('المجموع',
              style: NajmaTextStyles.body(color: NajmaColors.textSecond, size: 13)),
          Text(
            '${servicePrice.toStringAsFixed(0)} ر.س',
            style: NajmaTextStyles.heading(size: 20, color: NajmaColors.goldBright),
          ),
        ]),
      ]),
    );
  }
}

class _TimingSelector extends StatelessWidget {
  final String selected;
  final List<(String, String, String)> timings;
  final void Function(String) onSelect;
  const _TimingSelector({
    required this.selected,
    required this.timings,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: timings.indexed.map(((int, (String, String, String)) pair) {
        final (i, t) = pair;
        final active = selected == t.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(t.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(left: i < timings.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: active
                    ? NajmaColors.gold.withOpacity(0.1)
                    : NajmaColors.surface,
                border: Border.all(
                  color: active
                      ? NajmaColors.gold
                      : NajmaColors.goldDim.withOpacity(0.2),
                  width: active ? 1.2 : 0.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  t.$2,
                  style: NajmaTextStyles.caption(
                    size: 11,
                    color: active ? NajmaColors.gold : NajmaColors.textSecond,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NajmaFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? Function(String?)? validator;
  const _NajmaFormField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: NajmaTextStyles.body(size: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: NajmaTextStyles.body(size: 13, color: NajmaColors.textDim),
        filled: true,
        fillColor: NajmaColors.surface,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: NajmaColors.goldDim.withOpacity(0.3), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: NajmaColors.goldDim.withOpacity(0.3), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: NajmaColors.gold, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: NajmaColors.error, width: 0.8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: NajmaColors.error, width: 1),
        ),
        errorStyle: NajmaTextStyles.caption(size: 11, color: NajmaColors.error),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: NajmaTextStyles.caption(size: 12, color: NajmaColors.textSecond),
  );
}
