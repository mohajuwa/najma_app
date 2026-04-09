import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final s = AppStrings.of(context);
    final dir = LocaleNotifier.instance.textDirection;

    return Directionality(
      textDirection: dir,
      child: Scaffold(
        backgroundColor: NajmaColors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),

                // شعار — NAJM كبير + AL SAHRA صغير
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [
                      NajmaColors.goldDim,
                      NajmaColors.goldBright,
                      NajmaColors.gold,
                      NajmaColors.goldBright,
                      NajmaColors.goldDim,
                    ],
                  ).createShader(b),
                  child: const Text(
                    'NAJM',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 14,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'A L   S A H R A',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: NajmaColors.goldDim,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 90,
                  height: 0.7,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        NajmaColors.goldBright,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // العنوان
                Text(
                  s.whoAreYou,
                  style: NajmaTextStyles.display(size: 26),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  s.choiceToContinue,
                  style: NajmaTextStyles.caption(size: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // البطاقتين
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        emoji: '🎤',
                        titleAr: s.artist,
                        titleEn: 'ARTIST',
                        desc: s.artistDesc,
                        features: const [
                          'عرض خدماتك',
                          'استقبل الطلبات',
                          'ادر حجوزاتك',
                        ],
                        onTap: () => _select(context, 'artist'),
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _RoleCard(
                        emoji: '🥂',
                        titleAr: s.celebrant,
                        titleEn: 'CELEBRANT',
                        desc: s.celebrantDesc,
                        features: const [
                          'ابحث عن فنانين',
                          'احجز بسهولة',
                          'تتبع طلباتك',
                        ],
                        onTap: () => _select(context, 'fan'),
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _select(BuildContext context, String role) async {
    await LocalStorage.saveRole(role);
    if (context.mounted) context.push('/otp');
  }
}

class _RoleCard extends StatefulWidget {
  final String emoji, titleAr, titleEn, desc;
  final List<String> features;
  final VoidCallback onTap;
  final bool isPrimary;

  const _RoleCard({
    required this.emoji,
    required this.titleAr,
    required this.titleEn,
    required this.desc,
    required this.features,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) {
          _ctrl.forward();
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      NajmaColors.gold.withOpacity(0.18),
                      NajmaColors.surface,
                      NajmaColors.surface,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  )
                : null,
            color: widget.isPrimary ? null : NajmaColors.surface,
            border: Border.all(
              color: widget.isPrimary
                  ? NajmaColors.gold.withOpacity(0.55)
                  : NajmaColors.goldDim.withOpacity(0.18),
              width: widget.isPrimary ? 1.2 : 0.6,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: NajmaColors.gold.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // إيموجي في دائرة
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: NajmaColors.gold.withOpacity(0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NajmaColors.gold.withOpacity(0.25),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // الاسم
              Text(widget.titleAr, style: NajmaTextStyles.heading(size: 16)),
              const SizedBox(height: 2),
              Text(
                widget.titleEn,
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: NajmaColors.goldDim,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 10),

              // وصف مختصر
              Text(
                widget.desc,
                style: NajmaTextStyles.caption(
                  size: 11,
                  color: NajmaColors.textSecond,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // الميزات بنجمة ذهبية
              ...widget.features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '✦',
                        style: TextStyle(
                          fontSize: 7,
                          color: NajmaColors.gold.withOpacity(0.8),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          f,
                          style: NajmaTextStyles.caption(
                            size: 11,
                            color: NajmaColors.textSecond,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // زر الاختيار
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: widget.isPrimary
                      ? NajmaColors.gold
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.isPrimary
                        ? NajmaColors.gold
                        : NajmaColors.goldDim.withOpacity(0.40),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    widget.titleAr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: widget.isPrimary
                          ? NajmaColors.black
                          : NajmaColors.gold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
