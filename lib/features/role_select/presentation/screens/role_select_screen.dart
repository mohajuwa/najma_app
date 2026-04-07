
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

