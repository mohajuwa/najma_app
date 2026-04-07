import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/najma_top_bar.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NajmaColors.black,
      appBar: const NajmaTopBar(title: 'تسجيل الدخول'),
      body: Center(child: Text('OTP Screen — قادم', style: NajmaTextStyles.body())),
    );
  }
}
