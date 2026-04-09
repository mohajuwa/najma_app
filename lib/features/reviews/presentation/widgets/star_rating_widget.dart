import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// نجوم تفاعلية — تعمل للقراءة والكتابة
class StarRatingWidget extends StatelessWidget {
  final double rating;
  final int    starCount;
  final double size;
  final bool   interactive;
  final ValueChanged<int>? onChanged;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 28,
    this.interactive = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (i) {
        final filled = i < rating;
        final half   = !filled && i < rating + 0.5;
        final icon = filled
            ? Icons.star_rounded
            : half
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;

        final star = Icon(icon, color: NajmaColors.gold, size: size);

        return interactive
            ? GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onChanged?.call(i + 1);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: star,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: star,
              );
      }),
    );
  }
}
