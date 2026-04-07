import 'package:flutter/material.dart';
import 'app_colors.dart';

class NajmaTextStyles {
  static const fontAr = 'Tajawal';
  static const fontEn = 'PlayfairDisplay';

  static TextStyle display({double size = 32, Color? color}) => TextStyle(
    fontFamily: fontAr, fontSize: size, fontWeight: FontWeight.w900,
    color: color ?? NajmaColors.textPrimary, height: 1.3,
  );

  static TextStyle heading({double size = 22, Color? color}) => TextStyle(
    fontFamily: fontAr, fontSize: size, fontWeight: FontWeight.w700,
    color: color ?? NajmaColors.textPrimary,
  );

  static TextStyle subheading({double size = 16, Color? color}) => TextStyle(
    fontFamily: fontAr, fontSize: size, fontWeight: FontWeight.w600,
    color: color ?? NajmaColors.textSecond,
  );

  static TextStyle body({double size = 14, Color? color}) => TextStyle(
    fontFamily: fontAr, fontSize: size, fontWeight: FontWeight.w400,
    color: color ?? NajmaColors.textPrimary, height: 1.6,
  );

  static TextStyle caption({double size = 11, Color? color}) => TextStyle(
    fontFamily: fontAr, fontSize: size, fontWeight: FontWeight.w400,
    color: color ?? NajmaColors.textDim, letterSpacing: 0.5,
  );

  static TextStyle gold({double size = 14, FontWeight weight = FontWeight.w600}) => TextStyle(
    fontFamily: fontAr, fontSize: size, fontWeight: weight,
    color: NajmaColors.gold,
  );

  static TextStyle label({double size = 11, Color? color}) => TextStyle(
    fontFamily: fontEn, fontSize: size, fontWeight: FontWeight.w700,
    color: color ?? NajmaColors.goldDim, letterSpacing: 2,
  );
}
