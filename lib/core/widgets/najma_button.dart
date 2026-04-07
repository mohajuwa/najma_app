import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NajmaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool outlined;
  final double? width;
  final IconData? icon;

  const NajmaButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.outlined = false,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width ?? double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : NajmaColors.gold,
          border: Border.all(color: NajmaColors.gold, width: outlined ? 1 : 0),
        ),
        child: Center(
          child: isLoading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  color: NajmaColors.black, strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: outlined ? NajmaColors.gold : NajmaColors.black, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: NajmaTextStyles.body(size: 16, color: outlined ? NajmaColors.gold : NajmaColors.black)
                      .copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
