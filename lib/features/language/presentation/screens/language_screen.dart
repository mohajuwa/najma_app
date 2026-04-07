import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/widgets/najma_button.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'ar';

  final _langs = [
    {'code': 'ar', 'label': 'العربية', 'sub': 'Arabic'},
    {'code': 'en', 'label': 'English', 'sub': 'الإنجليزية'},
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
                Text('اختر لغتك', style: NajmaTextStyles.display(size: 28)),
                const SizedBox(height: 8),
                Text('Select your language', style: NajmaTextStyles.caption(size: 13)),
                const SizedBox(height: 40),
                ..._langs.map((l) => _LangTile(
                  code: l['code']!, label: l['label']!, sub: l['sub']!,
                  selected: _selected == l['code'],
                  onTap: () => setState(() => _selected = l['code']!),
                )),
                const Spacer(flex: 2),
                NajmaButton(
                  label: 'تأكيد',
                  onTap: () async {
                    await LocalStorage.saveLang(_selected);
                    if (mounted) context.go('/role-select');
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
  final String code, label, sub;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({required this.code, required this.label,
    required this.sub, required this.selected, required this.onTap});

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
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: NajmaTextStyles.heading(size: 16, color: selected ? NajmaColors.gold : NajmaColors.textPrimary)),
              Text(sub, style: NajmaTextStyles.caption()),
            ],
          )),
          if (selected) const Icon(Icons.check, color: NajmaColors.gold, size: 20),
        ]),
      ),
    );
  }
}
