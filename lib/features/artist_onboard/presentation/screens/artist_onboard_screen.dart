import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ArtistOnboardScreen extends StatelessWidget {
  const ArtistOnboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NajmaColors.black,
      body: Center(child: Text('Artist Onboard — قادم', style: NajmaTextStyles.body())),
    );
  }
}
