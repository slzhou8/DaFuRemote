import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/desktop/widgets/tabbar_widget.dart';

import 'modern_theme.dart';

class ThemeManager {
  ThemeManager._();

  static ThemeMode getThemeModePreference() => MyTheme.getThemeModePreference();

  static Future<void> changeDarkMode(ThemeMode mode) =>
      MyTheme.changeDarkMode(mode);

  static ThemeMode currentThemeMode() => MyTheme.currentThemeMode();

  static ThemeMode themeModeFromString(String value) =>
      MyTheme.themeModeFromString(value);

  static ThemeData getLightThemeData() => ModernTheme.lightTheme.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          ColorThemeExtension.light,
          TabbarTheme.light,
        ],
      );

  static ThemeData getDarkThemeData() => ModernTheme.darkTheme.copyWith(
        extensions: <ThemeExtension<dynamic>>[
          ColorThemeExtension.dark,
          TabbarTheme.dark,
        ],
      );
}

extension ThemeManagerExtension on BuildContext {
  ModernColors get modernColors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? ModernColors.dark : ModernColors.light;
  }
}

class ModernColors {
  final Color primary;
  final Color primaryVariant;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color border;

  const ModernColors({
    required this.primary,
    required this.primaryVariant,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.border,
  });

  static const ModernColors light = ModernColors(
    primary: ModernTheme.primaryLight,
    primaryVariant: ModernTheme.primaryLightVariant,
    secondary: ModernTheme.secondaryLight,
    background: ModernTheme.backgroundLight,
    surface: ModernTheme.surfaceLight,
    surfaceVariant: ModernTheme.surfaceVariantLight,
    textPrimary: ModernTheme.textPrimaryLight,
    textSecondary: ModernTheme.textSecondaryLight,
    textTertiary: ModernTheme.textTertiaryLight,
    success: ModernTheme.successLight,
    warning: ModernTheme.warningLight,
    error: ModernTheme.errorLight,
    info: ModernTheme.infoLight,
    border: ModernTheme.borderLight,
  );

  static const ModernColors dark = ModernColors(
    primary: ModernTheme.primaryDark,
    primaryVariant: ModernTheme.primaryDarkVariant,
    secondary: ModernTheme.secondaryDark,
    background: ModernTheme.backgroundDark,
    surface: ModernTheme.surfaceDark,
    surfaceVariant: ModernTheme.surfaceVariantDark,
    textPrimary: ModernTheme.textPrimaryDark,
    textSecondary: ModernTheme.textSecondaryDark,
    textTertiary: ModernTheme.textTertiaryDark,
    success: ModernTheme.successDark,
    warning: ModernTheme.warningDark,
    error: ModernTheme.errorDark,
    info: ModernTheme.infoDark,
    border: ModernTheme.borderDark,
  );
}
