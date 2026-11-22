import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shared sizes so screens feel consistent.
class AppSizes {
  AppSizes._();

  static const double radiusCard = 24;
  static const double radiusPill = 30;
  static const double buttonHeight = 58;
  static const double screenPadding = 24;
}

/// Luna app theme. Use it in main.dart: `theme: AppTheme.light`.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.text,
      tertiary: AppColors.warmAccent,
      onTertiary: AppColors.text,
      surface: AppColors.background,
      onSurface: AppColors.text,
      error: Color(0xFFB3426B),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}