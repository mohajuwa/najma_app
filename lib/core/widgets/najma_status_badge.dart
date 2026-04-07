import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum OrderStatus { pending, accepted, performing, delivered, completed, rejected }

class NajmaStatusBadge extends StatelessWidget {
  final OrderStatus status;
  const NajmaStatusBadge({super.key, required this.status});

  static const _labels = {
    OrderStatus.pending:    'قيد الانتظار',
    OrderStatus.accepted:   'مقبول',
    OrderStatus.performing: 'جاري التنفيذ',
    OrderStatus.delivered:  'تم التسليم',
    OrderStatus.completed:  'مكتمل',
    OrderStatus.rejected:   'مرفوض',
  };

  static const _colors = {
    OrderStatus.pending:    NajmaColors.pending,
    OrderStatus.accepted:   NajmaColors.accepted,
    OrderStatus.performing: NajmaColors.performing,
    OrderStatus.delivered:  NajmaColors.delivered,
    OrderStatus.completed:  NajmaColors.completed,
    OrderStatus.rejected:   NajmaColors.rejected,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _labels[status]!,
        style: NajmaTextStyles.caption(size: 11, color: color),
      ),
    );
  }
}
