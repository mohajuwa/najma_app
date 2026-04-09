import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/network/api_client.dart';

/// شاشة طلب أغنية خاصة أو أغنية هدية
/// تُستدعى من _ServiceCard عند category == custom_song | gift_song
class CustomSongRequestScreen extends StatefulWidget {
  final int    serviceId;
  final String serviceName;
  final String category;   // 'custom_song' | 'gift_song'
  final double price;
  final String artistName;
  final int    artistId;

  const CustomSongRequestScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required this.price,
    required this.artistName,
    required this.artistId,
  });

  @override
  State<CustomSongRequestScreen> createState() =>
      _CustomSongRequestScreenState();
}

class _CustomSongRequestScreenState
    extends State<CustomSongRequestScreen> {

  // حقول مشتركة
  final _nameCtrl     = TextEditingController();
  final _messageCtrl  = TextEditingController();

  // حقول gift_song فقط
  final _recipientCtrl    = TextEditingController();
  final _relationshipCtrl = TextEditingController();
  final _occasionCtrl     = TextEditingController();

  // حقول custom_song فقط
  final _customWordsCtrl = TextEditingController();

  // حقول الحجز
  final _phoneCtrl    = TextEditingController();
  DateTime? _timing;
  bool _isLoading = false;

  bool get _isGift => widget.category == 'gift_song';

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _messageCtrl, _recipientCtrl,
      _relationshipCtrl, _occasionCtrl,
      _customWordsCtrl, _phoneCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  // ── إرسال الطلب ──────────────────────────────────────────────
  Future<void> _submit() async {
    // validation
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('أدخل اسمك');
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      _showError('أدخل رقم جوالك');
      return;
    }
    if (_timing == null) {
      _showError('حدد التوقيت المطلوب');
      return;
    }
    if (_isGift && _recipientCtrl.text.trim().isEmpty) {
      _showError('أدخل اسم الشخص المُهدى إليه');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // تفاصيل الطلب الخاصة
      final Map<String, dynamic> orderDetails = _isGift
          ? {
              'recipient_name': _recipientCtrl.text.trim(),
              'relationship':   _relationshipCtrl.text.trim(),
              'occasion':       _occasionCtrl.text.trim(),
              'message':        _messageCtrl.text.trim(),
            }
          : {
              'custom_words': _customWordsCtrl.text.trim(),
              'message':      _messageCtrl.text.trim(),
            };

      await ApiClient.dio.post('orders', data: {
        'artist_id':    widget.artistId,
        'service_id':   widget.serviceId,
        'fan_name':     _nameCtrl.text.trim(),
        'fan_phone':    _phoneCtrl.text.trim(),
        'timing':       _timing!.toIso8601String(),
        'message':      _messageCtrl.text.trim(),
        'order_details': orderDetails,
      });

      if (mounted) {
        _showSuccess('تم إرسال طلبك بنجاح! سيتواصل معك الفنان قريباً');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.pop();
      }
    } catch (e) {
      _showError('فشل الإرسال — حاول مجدداً');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── اختيار التوقيت ────────────────────────────────────────────
  Future<void> _pickTiming() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: NajmaColors.gold,
            surface: NajmaColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: NajmaColors.gold,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      _timing = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final title = _isGift ? 'طلب أغنية هدية 🎁' : 'طلب أغنية خاصة 🎼';

    return Scaffold(
      backgroundColor: NajmaColors.black,
      appBar: AppBar(
        backgroundColor: NajmaColors.black,
        elevation: 0,
        title: Text(title, style: NajmaTextStyles.heading(size: 16)),
        iconTheme: const IconThemeData(color: NajmaColors.gold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── بطاقة الخدمة ──────────────────────────────────────
            _ServiceSummary(
              artistName:  widget.artistName,
              serviceName: widget.serviceName,
              price:       widget.price,
              isGift:      _isGift,
            ),
            const SizedBox(height: 24),

            // ── بياناتك ───────────────────────────────────────────
            _SectionHeader(title: 'بياناتك'),
            _Field(ctrl: _nameCtrl,  label: 'اسمك'),
            _Field(ctrl: _phoneCtrl, label: 'رقم الجوال',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),

            // ── التوقيت ───────────────────────────────────────────
            _SectionHeader(title: 'التوقيت المطلوب'),
            GestureDetector(
              onTap: _pickTiming,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NajmaColors.surface,
                  border: Border.all(
                    color: _timing != null
                        ? NajmaColors.gold.withOpacity(0.4)
                        : NajmaColors.goldDim.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: NajmaColors.gold, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _timing != null
                        ? '${_timing!.day}/${_timing!.month}/${_timing!.year}'
                          '  ${_timing!.hour.toString().padLeft(2,'0')}:'
                          '${_timing!.minute.toString().padLeft(2,'0')}'
                        : 'اختر التاريخ والوقت',
                    style: NajmaTextStyles.body(
                      size: 14,
                      color: _timing != null
                          ? NajmaColors.white
                          : NajmaColors.textDim,
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // ── تفاصيل الطلب ──────────────────────────────────────
            if (_isGift) ...[
              _SectionHeader(title: 'تفاصيل الهدية 🎁'),
              _Field(ctrl: _recipientCtrl,   label: 'اسم الشخص المُهدى إليه'),
              _Field(ctrl: _relationshipCtrl,label: 'صلة القرابة (مثل: أم، صديق، حبيب...)'),
              _Field(ctrl: _occasionCtrl,    label: 'المناسبة (مثل: عيد ميلاد، زواج...)'),
              _Field(
                ctrl:     _messageCtrl,
                label:    'رسالة تريدها في الأغنية (اختياري)',
                maxLines: 4,
              ),
            ] else ...[
              _SectionHeader(title: 'تفاصيل الأغنية 🎵'),
              _Field(
                ctrl:     _customWordsCtrl,
                label:    'كلمات أو عبارات تريدها في الأغنية',
                maxLines: 4,
                hint:     'مثل: اسمي محمد، أحب الموسيقى الشرقية...',
              ),
              _Field(
                ctrl:     _messageCtrl,
                label:    'ملاحظات إضافية (اختياري)',
                maxLines: 2,
              ),
            ],

            const SizedBox(height: 32),

            // ── زر الإرسال ────────────────────────────────────────
            _SummaryRow(label: 'المبلغ الإجمالي',
                value: '${widget.price.toStringAsFixed(0)} ر.س'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NajmaColors.gold,
                  disabledBackgroundColor:
                      NajmaColors.gold.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: NajmaColors.black))
                    : Text('أرسل الطلب للفنان',
                        style: NajmaTextStyles.heading(size: 15,
                            color: NajmaColors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg), backgroundColor: NajmaColors.success));

  void _showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg), backgroundColor: NajmaColors.error));
}

// ── Helpers ───────────────────────────────────────────────────────

class _ServiceSummary extends StatelessWidget {
  final String artistName, serviceName;
  final double price;
  final bool   isGift;
  const _ServiceSummary({
    required this.artistName,
    required this.serviceName,
    required this.price,
    required this.isGift,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NajmaColors.gold.withOpacity(0.06),
        border: Border.all(
            color: NajmaColors.gold.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Text(isGift ? '🎁' : '🎼',
            style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(serviceName,
                style: NajmaTextStyles.heading(size: 14)),
            Text('الفنان: $artistName',
                style: NajmaTextStyles.caption(
                    color: NajmaColors.textSecond)),
          ],
        )),
        Text('${price.toStringAsFixed(0)} ر.س',
            style: NajmaTextStyles.heading(
                size: 18, color: NajmaColors.gold)),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(width: 3, height: 16, color: NajmaColors.gold),
        const SizedBox(width: 8),
        Text(title, style: NajmaTextStyles.heading(size: 14)),
      ]),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String? hint;
  final int    maxLines;
  final TextInputType keyboardType;

  const _Field({
    required this.ctrl,
    required this.label,
    this.hint,
    this.maxLines    = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller:   ctrl,
        maxLines:     maxLines,
        keyboardType: keyboardType,
        style: NajmaTextStyles.body(size: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText:  hint,
          labelStyle: NajmaTextStyles.caption(
              color: NajmaColors.textSecond),
          hintStyle: NajmaTextStyles.caption(
              color: NajmaColors.textDim),
          filled: true,
          fillColor: NajmaColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: NajmaColors.goldDim.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: NajmaColors.goldDim.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                color: NajmaColors.gold, width: 1),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: NajmaTextStyles.body(
          color: NajmaColors.textSecond)),
      const Spacer(),
      Text(value, style: NajmaTextStyles.heading(
          size: 18, color: NajmaColors.gold)),
    ]);
  }
}
