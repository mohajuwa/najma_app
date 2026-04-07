import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NajmaColors.black,
      body: Center(child: Text('Order Tracking #\$orderId — قادم', style: NajmaTextStyles.body())),
    );
  }
}
