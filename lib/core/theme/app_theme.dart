import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// MetJou brand colours.
abstract final class AppColors {
  static const primary = Color(0xffB271AA);
  static const primaryLight = Color(0xffC98BC1);
}

ThemeData _theme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: scheme,
    fontFamily: 'ReadexPro',
    scaffoldBackgroundColor: scheme.surface,
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: scheme.onSurface,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
    ),
  );
}

final appTheme = _theme(Brightness.light);
final appDarkTheme = _theme(Brightness.dark);

const _prefsKey = "themeMode";

/// Light, dark or following the phone (the default).
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);

Future<void> loadThemeMode() async {
  final name = (await SharedPreferences.getInstance()).getString(_prefsKey);
  appThemeMode.value = ThemeMode.values.firstWhere(
    (m) => m.name == name,
    orElse: () => ThemeMode.system,
  );
}

Future<void> setThemeMode(ThemeMode mode) async {
  await (await SharedPreferences.getInstance()).setString(_prefsKey, mode.name);
  appThemeMode.value = mode;
}
