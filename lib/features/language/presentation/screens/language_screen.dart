
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

