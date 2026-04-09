import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_notifier.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});
  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late String _selected;

  final _langs = const [
    {'code': 'ar', 'label': 'العربية',  'sub': 'Arabic',     'flag': '🇸🇦'},
    {'code': 'en', 'label': 'English',  'sub': 'الإنجليزية', 'flag': '🇬🇧'},
  ];

  @override
  void initState() {
    super.initState();
    _selected = LocalStorage.getLang() ?? 'ar';
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Directionality(
      textDirection: s.isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: NajmaColors.black,
        body: SafeArea(
          child: Column(children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                    color: NajmaColors.goldDim.withOpacity(0.15))),
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
                Text(s.language, style: NajmaTextStyles.heading(size: 17)),
              ]),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.chooseAppLang,
                        style: NajmaTextStyles.body(
                            size: 14, color: NajmaColors.textSecond)),
                    const SizedBox(height: 20),
                    ..._langs.map((l) => _LangTile(
                      code:     l['code']!,
                      label:    l['label']!,
                      sub:      l['sub']!,
                      flag:     l['flag']!,
                      selected: _selected == l['code'],
                      onTap:    () => setState(() => _selected = l['code']!),
                    )),
                    const Spacer(),
                    GestureDetector(
                      onTap: _apply,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [NajmaColors.goldDim, NajmaColors.gold],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: NajmaColors.gold.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(s.apply,
                              style: NajmaTextStyles.body(size: 16,
                                  color: NajmaColors.black)
                                  .copyWith(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _apply() async {
    await LocalStorage.saveLang(_selected);
    LocaleNotifier.instance.setLocale(_selected);
    if (mounted) context.pop();
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? NajmaColors.gold.withOpacity(0.08)
              : NajmaColors.surface,
          border: Border.all(
            color: selected ? NajmaColors.gold : NajmaColors.goldDim.withOpacity(0.2),
            width: selected ? 1.5 : 0.8,
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: selected
              ? [BoxShadow(color: NajmaColors.gold.withOpacity(0.1), blurRadius: 16)]
              : [],
        ),
        child: Row(children: [
          Text(flag, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: NajmaTextStyles.heading(size: 15,
                      color: selected ? NajmaColors.gold : NajmaColors.textPrimary)),
              const SizedBox(height: 2),
              Text(sub, style: NajmaTextStyles.caption()),
            ],
          )),
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
