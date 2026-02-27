import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────
  //  Dark-mode palette
  // ─────────────────────────────────────────────
  static const Color background = Color(0xFF0A0D12);
  static const Color surface = Color(0xFF151921);
  static const Color primary = Color(0xFF22D3EE);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textPrimary = Colors.white;
  static const Color button = Color.fromARGB(168, 56, 56, 56);

  // ─────────────────────────────────────────────
  //  Light-mode palette  (light1 → light4)
  // ─────────────────────────────────────────────
  static const Color light1 = Color(0xFFF5F6F7); // scaffold / background
  static const Color light2 = Color(0xFFC1C4C8); // borders / subtle surfaces
  static const Color light3 = Color(0xFF7B7F85); // secondary text
  static const Color light4 = Color(0xFF2B2E33); // primary text

  // ─────────────────────────────────────────────
  //  Theme-aware helpers
  // ─────────────────────────────────────────────
  static Color backgroundFor(bool isLight) => isLight ? light1 : background;

  static Color surfaceFor(bool isLight) => isLight ? Colors.white : surface;

  static Color textPrimaryFor(bool isLight) => isLight ? light4 : textPrimary;

  static Color textSecondaryFor(bool isLight) =>
      isLight ? light3 : textSecondary;

  static Color containerColor(bool isLight) =>
      isLight ? Colors.white : const Color(0xFF151921);

  static Color borderColor(bool isLight) =>
      isLight ? light2 : const Color(0xFF2D3748);

  static Color shadowColor(bool isLight) =>
      isLight ? Colors.black.withOpacity(0.08) : Colors.black.withOpacity(0.4);

  static Color inputFillColor(bool isLight) =>
      isLight ? const Color(0xFFF8F9FA) : surface;

  static Color cardOverlay(bool isLight) =>
      isLight ? light2.withOpacity(0.15) : Colors.white.withOpacity(0.08);

  static Color iconColor(bool isLight) => isLight ? light3 : textSecondary;

  static Color dividerColor(bool isLight) =>
      isLight ? light2.withOpacity(0.6) : Colors.white12;

  static List<Color> gradientColors(bool isLight) => isLight
      ? [light1, const Color(0xFFE8EAED)]
      : [const Color(0xFF00365D), Colors.black];
}
