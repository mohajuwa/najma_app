import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NajmaGoldDivider extends StatelessWidget {
  final double opacity;
  const NajmaGoldDivider({super.key, this.opacity = 0.3});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            NajmaColors.gold.withOpacity(opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
