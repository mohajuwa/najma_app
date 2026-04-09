import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NajmaButton extends StatefulWidget {
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
    this.outlined  = false,
    this.width,
    this.icon,
  });

  @override
  State<NajmaButton> createState() => _NajmaButtonState();
}

class _NajmaButtonState extends State<NajmaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onTapDown(_) {
    if (widget.isLoading || widget.onTap == null) return;
    _ctrl.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(_) { _ctrl.reverse(); widget.onTap?.call(); }
  void _onTapCancel() { _ctrl.reverse(); }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.isLoading || widget.onTap == null;

    return GestureDetector(
      onTapDown   : disabled ? null : _onTapDown,
      onTapUp     : disabled ? null : _onTapUp,
      onTapCancel : disabled ? null : _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width : widget.width ?? double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: widget.outlined
                ? Colors.transparent
                : disabled
                    ? NajmaColors.goldDim.withOpacity(0.4)
                    : NajmaColors.gold,
            border: Border.all(
              color: disabled
                  ? NajmaColors.goldDim.withOpacity(0.3)
                  : NajmaColors.gold,
              width: widget.outlined ? 1 : 0,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      color: widget.outlined ? NajmaColors.gold : NajmaColors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon,
                          color: widget.outlined ? NajmaColors.gold : NajmaColors.black,
                          size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: NajmaTextStyles.body(
                        size: 16,
                        color: widget.outlined ? NajmaColors.gold : NajmaColors.black,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ]),
          ),
        ),
      ),
    );
  }
}
