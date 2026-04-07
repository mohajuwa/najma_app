import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ArtistProfileScreen extends StatelessWidget {
  final String artistId;
  const ArtistProfileScreen({super.key, required this.artistId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NajmaColors.black,
      body: Center(child: Text('Artist Profile #\$artistId — قادم', style: NajmaTextStyles.body())),
    );
  }
}
