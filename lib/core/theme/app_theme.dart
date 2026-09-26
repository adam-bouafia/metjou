import 'package:flutter/material.dart';

/// MetJou brand colours.
abstract final class AppColors {
  static const primary = Color(0xffB271AA);
  static const primaryLight = Color(0xffC98BC1);
}

final appTheme = ThemeData(
  fontFamily: 'ReadexPro',
  colorSchemeSeed: AppColors.primary,
);
