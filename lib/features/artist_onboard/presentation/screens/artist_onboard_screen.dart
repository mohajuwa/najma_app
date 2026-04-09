import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/najma_button.dart';
import '../bloc/onboard_bloc.dart';

// ── أنواع الخدمات المتاحة ──────────────────────────────────────────
const _serviceTypes = [
  ('setlist',          'قائمة أغاني — Setlist'),
  ('normal_greeting',  'تهنئة عادية'),
  ('special_greeting', 'تهنئة مميزة'),
  ('vip_greeting',     'تهنئة VIP'),
  ('booking',          'حجز خاص'),
];

// ── أنواع التخصصات ─────────────────────────────────────────────────
const _genres = [
  'طرب عربي', 'شعبي', 'خليجي', 'كلاسيكي', 'جاز', 'روك', 'هيب هوب',
  'إلكترونيك', 'فلكلور', 'ديني', 'أطفال', 'أخرى',
];

class ArtistOnboardScreen extends StatelessWidget {
  const ArtistOnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardBloc(),
      child: const _OnboardBody(),
    );
  }
}

class _OnboardBody extends StatefulWidget {
  const _OnboardBody();
  @override
  State<_OnboardBody> createState() => _OnboardBodyState();
}

class _OnboardBodyState extends State<_OnboardBody>
    with TickerProviderStateMixin {
  int _step = 0;

  // خطوة 1
  final _bioArCtrl = TextEditingController();
  final _bioEnCtrl = TextEditingController();
  final _ibanCtrl  = TextEditingController();
  final _bankCtrl  = TextEditingController();
  String _genre    = _genres.first;
  final _formKey1  = GlobalKey<FormState>();

  // خطوة 2
  String _serviceType  = _serviceTypes.first.$1;
  final _svcNameCtrl   = TextEditingController();
  final _svcPriceCtrl  = TextEditingController();
  final _svcDescCtrl   = TextEditingController();
  final _formKey2      = GlobalKey<FormState>();

  late AnimationController _slideCtrl;
  late Animation<Offset>   _slideAnim;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut);
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _bioArCtrl.dispose();
    _bioEnCtrl.dispose();
    _ibanCtrl.dispose();
    _bankCtrl.dispose();
    _svcNameCtrl.dispose();
    _svcPriceCtrl.dispose();
    _svcDescCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _animateStep(int step) {
    setState(() => _step = step);
    _slideCtrl.reset();
    _slideCtrl.forward();
  }

  void _submitProfile() {
    if (!_formKey1.currentState!.validate()) return;
    context.read<OnboardBloc>().add(SubmitProfileEvent(
      bioAr:    _bioArCtrl.text.trim(),
      bioEn:    _bioEnCtrl.text.trim().isEmpty ? null : _bioEnCtrl.text.trim(),
      genre:    _genre,
      iban:     _ibanCtrl.text.trim().isEmpty ? null : _ibanCtrl.text.trim(),
      bankName: _bankCtrl.text.trim().isEmpty ? null : _bankCtrl.text.trim(),
    ));
  }

  void _addService() {
    if (!_formKey2.currentState!.validate()) return;
    final price = double.tryParse(_svcPriceCtrl.text.trim()) ?? 0;
    context.read<OnboardBloc>().add(AddServiceEvent(
      type:          _serviceType,
      nameAr:        _svcNameCtrl.text.trim(),
      price:         price,
      descriptionAr: _svcDescCtrl.text.trim().isEmpty
                         ? null : _svcDescCtrl.text.trim(),
    ));
    _svcNameCtrl.clear();
    _svcPriceCtrl.clear();
    _svcDescCtrl.clear();
    setState(() => _serviceType = _serviceTypes.first.$1);
    FocusScope.of(context).unfocus();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: NajmaTextStyles.body(size: 13, color: Colors.white),
          textDirection: TextDirection.rtl),
      backgroundColor: NajmaColors.error,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardBloc, OnboardState>(
      listener: (ctx, state) {
        if (state is ProfileSubmitted) _animateStep(1);
        if (state is OnboardDone) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('تم التسجيل بنجاح! سيتم مراجعة ملفك قريباً',
                style: NajmaTextStyles.body(size: 13, color: Colors.white),
                textDirection: TextDirection.rtl),
            backgroundColor: NajmaColors.success,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 3),
          ));
          Future.delayed(const Duration(milliseconds: 500), () {
            if (ctx.mounted) ctx.go('/artist-dashboard');
          });
        }
        if (state is OnboardError) _showError(state.message);
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: NajmaColors.black,
          body: SafeArea(
            child: Column(children: [
              _TopBar(
                step: _step,
                onBack: _step == 1 ? () => _animateStep(0) : null,
              ),
              _StepIndicator(step: _step),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _step == 0
                        ? _Step1Profile(
                            formKey: _formKey1,
                            bioArCtrl: _bioArCtrl,
                            bioEnCtrl: _bioEnCtrl,
                            ibanCtrl:  _ibanCtrl,
                            bankCtrl:  _bankCtrl,
                            genre:     _genre,
                            onGenreChanged: (v) => setState(() => _genre = v!),
                            onSubmit:  _submitProfile,
                          )
                        : _Step2Services(
                            formKey:       _formKey2,
                            svcNameCtrl:   _svcNameCtrl,
                            svcPriceCtrl:  _svcPriceCtrl,
                            svcDescCtrl:   _svcDescCtrl,
                            serviceType:   _serviceType,
                            onTypeChanged: (v) => setState(() => _serviceType = v!),
                            onAddService:  _addService,
                          ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────── Top Bar ─────────────────────────
class _TopBar extends StatelessWidget {
  final int step;
  final VoidCallback? onBack;
  const _TopBar({required this.step, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        GestureDetector(
          onTap: onBack ?? () => context.go('/artist-dashboard'),
          child: Icon(
            onBack != null ? Icons.arrow_back_ios : Icons.close,
            color: onBack != null ? NajmaColors.gold : NajmaColors.textDim,
            size: 21,
          ),
        ),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text('تسجيل كفنان', style: NajmaTextStyles.heading(size: 16)),
          Text('ARTIST ONBOARDING', style: NajmaTextStyles.label()),
        ]),
        const Spacer(),
        const SizedBox(width: 21),
      ]),
    );
  }
}

// ─────────────────────────────── Step Indicator ──────────────────
class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(children: [
        _StepDot(n: 1, active: step == 0, done: step > 0, label: 'معلوماتي'),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.only(bottom: 18),
            color: step > 0 ? NajmaColors.gold : NajmaColors.surface,
          ),
        ),
        _StepDot(n: 2, active: step == 1, done: false, label: 'خدماتي'),
      ]),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int n;
  final bool active, done;
  final String label;
  const _StepDot({required this.n, required this.active,
      required this.done, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = (active || done) ? NajmaColors.gold : NajmaColors.textDim;
    return Column(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: done ? NajmaColors.gold
              : active ? NajmaColors.gold.withOpacity(0.12)
              : NajmaColors.surface,
          border: Border.all(color: color, width: active ? 2 : 1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: done
              ? const Icon(Icons.check, color: NajmaColors.black, size: 16)
              : Text('$n',
                  style: NajmaTextStyles.body(size: 14, color: color)
                      .copyWith(fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 4),
      Text(label,
          style: NajmaTextStyles.caption(size: 10, color: color)
              .copyWith(fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
    ]);
  }
}

// ─────────────────────────────── Step 1: Profile ─────────────────
class _Step1Profile extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController bioArCtrl, bioEnCtrl, ibanCtrl, bankCtrl;
  final String genre;
  final ValueChanged<String?> onGenreChanged;
  final VoidCallback onSubmit;

  const _Step1Profile({
    required this.formKey,
    required this.bioArCtrl,
    required this.bioEnCtrl,
    required this.ibanCtrl,
    required this.bankCtrl,
    required this.genre,
    required this.onGenreChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Form(
        key: formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SectionTitle('النبذة التعريفية', 'من أنت؟ أخبر المحتفلين عنك'),
          const SizedBox(height: 16),
          _NajmaField(
            controller: bioArCtrl,
            label: 'نبذة بالعربي *',
            hint: 'أنا فنان...',
            maxLines: 3,
            maxLength: 500,
            validator: (v) => (v == null || v.trim().length < 10)
                ? 'الرجاء كتابة نبذة لا تقل عن 10 أحرف'
                : null,
          ),
          const SizedBox(height: 14),
          _NajmaField(
            controller: bioEnCtrl,
            label: 'نبذة بالإنجليزي (اختياري)',
            hint: 'I am an artist...',
            maxLines: 2,
            maxLength: 500,
            textDir: TextDirection.ltr,
          ),
          const SizedBox(height: 22),
          _SectionTitle('التخصص الموسيقي', 'اختر نوع فنك'),
          const SizedBox(height: 12),
          _NajmaDropdown<String>(
            value: genre,
            label: 'التخصص *',
            items: _genres.map((g) =>
                DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: onGenreChanged,
          ),
          const SizedBox(height: 22),
          _SectionTitle('معلومات بنكية (اختياري)', 'لاستلام مدفوعاتك'),
          const SizedBox(height: 16),
          _NajmaField(
            controller: ibanCtrl,
            label: 'رقم IBAN',
            hint: 'SA...',
            textDir: TextDirection.ltr,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(34),
            ],
          ),
          const SizedBox(height: 14),
          _NajmaField(
            controller: bankCtrl,
            label: 'اسم البنك',
            hint: 'بنك الراجحي...',
          ),
          const SizedBox(height: 32),
          BlocBuilder<OnboardBloc, OnboardState>(
            builder: (ctx, state) => NajmaButton(
              label: 'التالي — إضافة الخدمات',
              isLoading: state is OnboardLoading,
              onTap: onSubmit,
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────── Step 2: Services ────────────────
class _Step2Services extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController svcNameCtrl, svcPriceCtrl, svcDescCtrl;
  final String serviceType;
  final ValueChanged<String?> onTypeChanged;
  final VoidCallback onAddService;

  const _Step2Services({
    required this.formKey,
    required this.svcNameCtrl,
    required this.svcPriceCtrl,
    required this.svcDescCtrl,
    required this.serviceType,
    required this.onTypeChanged,
    required this.onAddService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionTitle('أضف خدماتك', 'حدد الخدمات التي تقدمها وأسعارها'),
            const SizedBox(height: 20),

            // قائمة الخدمات المضافة
            BlocBuilder<OnboardBloc, OnboardState>(
              builder: (ctx, state) {
                final svcList = state is ServiceAdded ? state.services : <Map<String, dynamic>>[];
                if (svcList.isEmpty) return _EmptyHint();
                return Column(
                  children: svcList.asMap().entries.map((e) => _ServiceChip(
                    index: e.key,
                    data: e.value,
                    onRemove: () => ctx.read<OnboardBloc>()
                        .add(RemoveLocalServiceEvent(e.key)),
                  )).toList(),
                );
              },
            ),

            const SizedBox(height: 20),
            Container(
              height: 1,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [
                NajmaColors.goldDim.withOpacity(0),
                NajmaColors.goldDim.withOpacity(0.4),
                NajmaColors.goldDim.withOpacity(0),
              ])),
            ),
            const SizedBox(height: 20),

            Text('إضافة خدمة جديدة', style: NajmaTextStyles.subheading(size: 14)),
            const SizedBox(height: 14),

            Form(
              key: formKey,
              child: Column(children: [
                _NajmaDropdown<String>(
                  value: serviceType,
                  label: 'نوع الخدمة *',
                  items: _serviceTypes.map((t) =>
                      DropdownMenuItem(value: t.$1, child: Text(t.$2))).toList(),
                  onChanged: onTypeChanged,
                ),
                const SizedBox(height: 12),
                _NajmaField(
                  controller: svcNameCtrl,
                  label: 'اسم الخدمة *',
                  hint: 'تهنئة عروس...',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'أدخل اسم الخدمة' : null,
                ),
                const SizedBox(height: 12),
                _NajmaField(
                  controller: svcPriceCtrl,
                  label: 'السعر (ريال) *',
                  hint: '500',
                  textDir: TextDirection.ltr,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n < 1) return 'أدخل سعراً صحيحاً (1 ريال فأكثر)';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _NajmaField(
                  controller: svcDescCtrl,
                  label: 'وصف الخدمة (اختياري)',
                  hint: 'تفاصيل إضافية...',
                  maxLines: 2,
                ),
              ]),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: NajmaColors.gold,
                side: const BorderSide(color: NajmaColors.gold),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: onAddService,
              icon: const Icon(Icons.add, size: 18),
              label: Text('إضافة الخدمة',
                  style: NajmaTextStyles.body(size: 14, color: NajmaColors.gold)),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),

      // زر الإنهاء ثابت
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: BlocBuilder<OnboardBloc, OnboardState>(
          builder: (ctx, state) {
            final services = state is ServiceAdded ? state.services : <Map<String, dynamic>>[];
            final isSubmitting = state is ServicesSubmitting;
            final canFinish   = services.isNotEmpty;

            String label = 'إنهاء التسجيل';
            if (isSubmitting) {
              label = 'جارٍ الإرسال ${state.current}/${state.total}';
            } else if (canFinish) {
              label = 'إنهاء التسجيل (${services.length} خدمة)';
            }

            return Column(children: [
              if (!canFinish && !isSubmitting)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('أضف خدمة واحدة على الأقل للمتابعة',
                      style: NajmaTextStyles.caption(
                          size: 11, color: NajmaColors.textDim),
                      textAlign: TextAlign.center),
                ),
              NajmaButton(
                label: label,
                isLoading: isSubmitting,
                onTap: canFinish
                    ? () => ctx.read<OnboardBloc>().add(FinishOnboardEvent())
                    : null,
              ),
            ]);
          },
        ),
      ),
    ]);
  }
}

// ─────────────────────────────── Service Chip ────────────────────
class _ServiceChip extends StatelessWidget {
  final int index;
  final Map<String, dynamic> data;
  final VoidCallback onRemove;
  const _ServiceChip({required this.index, required this.data, required this.onRemove});

  String get _label {
    final t = data['type'] as String? ?? '';
    return _serviceTypes.firstWhere((e) => e.$1 == t, orElse: () => (t, t)).$2;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(color: NajmaColors.gold.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: NajmaColors.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(_label,
              style: NajmaTextStyles.caption(size: 10, color: NajmaColors.gold)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(data['name_ar'] as String? ?? '',
            style: NajmaTextStyles.body(size: 13))),
        Text('${data['price']} ر.س',
            style: NajmaTextStyles.body(size: 13, color: NajmaColors.goldBright)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.remove_circle_outline,
              color: NajmaColors.error, size: 18),
        ),
      ]),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(color: NajmaColors.goldDim.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline, color: NajmaColors.goldDim, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text('لم تُضف أي خدمات بعد.\nأضف خدمة واحدة على الأقل.',
            style: NajmaTextStyles.caption(size: 12, color: NajmaColors.textSecond))),
      ]),
    );
  }
}

// ─────────────────────────────── Section Title ───────────────────
class _SectionTitle extends StatelessWidget {
  final String title, subtitle;
  const _SectionTitle(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 3, height: 36, color: NajmaColors.gold),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: NajmaTextStyles.heading(size: 15)),
        Text(subtitle, style: NajmaTextStyles.caption(
            size: 11, color: NajmaColors.textSecond)),
      ]),
    ]);
  }
}

// ─────────────────────────────── Text Field ──────────────────────
class _NajmaField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final int? maxLength;
  final TextDirection textDir;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _NajmaField({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines  = 1,
    this.maxLength,
    this.textDir   = TextDirection.rtl,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: NajmaTextStyles.caption(
          size: 11, color: NajmaColors.textSecond)),
      const SizedBox(height: 6),
      TextFormField(
        controller:      controller,
        maxLines:        maxLines,
        maxLength:       maxLength,
        textDirection:   textDir,
        keyboardType:    keyboardType,
        inputFormatters: inputFormatters,
        validator:       validator,
        style: NajmaTextStyles.body(size: 14),
        decoration: InputDecoration(
          hintText:       hint,
          hintStyle:      NajmaTextStyles.caption(size: 13, color: NajmaColors.textDim),
          counterStyle:   NajmaTextStyles.caption(size: 10),
          filled:         true,
          fillColor:      NajmaColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: NajmaColors.goldDim.withOpacity(0.25)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: NajmaColors.goldDim.withOpacity(0.25)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: NajmaColors.gold, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: NajmaColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: NajmaColors.error, width: 1.5),
          ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────── Dropdown ────────────────────────
class _NajmaDropdown<T> extends StatelessWidget {
  final T value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _NajmaDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: NajmaTextStyles.caption(
          size: 11, color: NajmaColors.textSecond)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: NajmaColors.surface,
          border: Border.all(color: NajmaColors.goldDim.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value:         value,
            items:         items,
            onChanged:     onChanged,
            isExpanded:    true,
            dropdownColor: NajmaColors.surface2,
            style:         NajmaTextStyles.body(size: 14),
            iconEnabledColor: NajmaColors.gold,
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
        ),
      ),
    ]);
  }
}
