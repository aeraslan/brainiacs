import 'package:flutter/material.dart';

abstract final class AppColors {
  // Surfaces
  static const Color background = Color(0xFFF4F6F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF9F9FB);

  // Vibrant accents
  static const Color coral = Color(0xFFFF6B6B);
  static const Color mint = Color(0xFF4ECDC4);
  static const Color sunnyYellow = Color(0xFFFFE66D);
  static const Color electricBlue = Color(0xFF45B7D1);
  static const Color vibrantPurple = Color(0xFF9B5DE5);

  // Semantic aliases (backward-compatible call sites)
  static const Color primary = coral;
  static const Color accent = electricBlue;

  // Text
  static const Color textPrimary = Color(0xFF2B2D42);
  static const Color textSecondary = Color(0xFF5C5F77);
  static const Color onAccent = Color(0xFFFFFFFF);

  // Feedback
  static const Color correct = Color(0xFF00C853);
  static const Color incorrect = Color(0xFFFF1744);

  // Shadows
  static const Color shadow = Color(0x1A000000);

  // Number pad
  static const Color padGradientStart = Color(0xFFE4E7EC);
  static const Color padGradientEnd = Color(0xFF6E7888);
  static const Color padBorder = Color(0xFF5A6370);
  static const Color buttonFill = padGradientEnd;

  // Timer HUD
  static const Color timerGradientStart = electricBlue;
  static const Color timerGradientEnd = coral;
  static const Color timerBorder = Color(0xFF2B2D42);
  static const Color timerRemaining = Color(0xFF2B2D42);
  static const Color timerElapsed = incorrect;

  // Score on light backgrounds
  static const Color scoreOnLight = textPrimary;
  static const Color scoreLabelOnLight = textSecondary;

  /// All vibrant accent colors, cycled for buttons and icons.
  static const List<Color> accentPalette = [
    coral,
    mint,
    sunnyYellow,
    electricBlue,
    vibrantPurple,
  ];
}
