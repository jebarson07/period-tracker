import 'package:flutter/material.dart';

/// Unified 2.5D Kawaii design system colors for Luna Tracker.
///
/// Use these everywhere so all screens (Home, Calendar, Care, Settings)
/// share an identical, cohesive visual identity.
class AppColors {
  AppColors._();

  // Unified 2.5D Kawaii Palette
  static const primary = Color(0xFFF5A6C8); // Primary Kawaii Pink
  static const lightPink = Color(0xFFFCE4EF); // Surface Tint / Light Pink
  static const lavender = Color(0xFFE9DDFB); // Soft Lavender
  static const peach = Color(0xFFFFE4D2); // Soft Peach
  static const cream = Color(0xFFFFF7EC); // Warm Cream
  static const darkText = Color(0xFF704B69); // Main Dark Plum Text
  static const secondaryText = Color(0xFF987A96); // Muted Text
  static const period = Color(0xFFF4A6C6); // Period Day Highlight
  static const background = Color(0xFFFDEFF3); // Primary Background

  // Aliases & Supporting Colors
  static const text = darkText;
  static const textMuted = secondaryText;
  static const secondary = lavender;
  static const lavenderSoft = Color(0xFFD5BDEB); // borders
  static const warmAccent = peach;
  static const onPrimary = Colors.white;
  static const white = Colors.white;
  static const sage = Color(0xFF76B98A); // Fertile / Rest Green

  // Gradients
  static const ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF5A6C8), Color(0xFFE28BB4)],
  );

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFDEFF3),
      Color(0xFFFCE4EF),
      Color(0xFFF9E0EE),
    ],
  );
}
