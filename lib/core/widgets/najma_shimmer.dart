import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NajmaShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const NajmaShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 60,
    this.radius = 4,
  });

  @override
  State<NajmaShimmer> createState() => _NajmaShimmerState();
}

class _NajmaShimmerState extends State<NajmaShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: [
              (_anim.value - 0.3).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.3).clamp(0.0, 1.0),
            ],
            colors: const [
              NajmaColors.surface2,
              Color(0xFF2A2518),
              NajmaColors.surface2,
            ],
          ),
        ),
      ),
    );
  }
}
