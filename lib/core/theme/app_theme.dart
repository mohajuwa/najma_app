import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class NajmaTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: NajmaColors.black,
    colorScheme: const ColorScheme.dark(
      primary:   NajmaColors.gold,
      secondary: NajmaColors.goldBright,
      surface:   NajmaColors.surface,
      error:     NajmaColors.error,
    ),
    fontFamily: NajmaTextStyles.fontAr,
    appBarTheme: const AppBarTheme(
      backgroundColor: NajmaColors.black,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: NajmaColors.gold),
      titleTextStyle: TextStyle(
        color: NajmaColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: NajmaTextStyles.fontAr,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NajmaColors.gold,
        foregroundColor: NajmaColors.black,
        minimumSize: const Size(double.infinity, 52),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: NajmaTextStyles.fontAr,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NajmaColors.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: NajmaColors.goldDim, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: NajmaColors.goldDim, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: NajmaColors.gold, width: 1),
      ),
      hintStyle: const TextStyle(color: NajmaColors.textDim, fontFamily: NajmaTextStyles.fontAr),
      labelStyle: const TextStyle(color: NajmaColors.textSecond, fontFamily: NajmaTextStyles.fontAr),
    ),
  );
}
