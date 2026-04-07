import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NajmaTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? leading;

  const NajmaTopBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: NajmaColors.black,
      elevation: 0,
      centerTitle: true,
      leading: showBack
        ? GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_forward_ios, color: NajmaColors.gold, size: 20),
          )
        : leading,
      title: Text(title, style: NajmaTextStyles.heading(size: 18)),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: NajmaColors.goldDim.withOpacity(0.3)),
      ),
    );
  }
}
