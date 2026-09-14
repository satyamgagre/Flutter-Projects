import 'package:flutter/material.dart';

/// Color palette for S8YA Music Player.
///
/// Provides themed color sets for light, dark, and AMOLED modes,
/// plus a selection of accent colors for user customization.
class AppColors {
  AppColors._();

  // --- Accent Color Options ---
  static const List<Color> accentColors = [
    Color(0xFF6750A4), // Purple (default)
    Color(0xFF0061A4), // Blue
    Color(0xFF006E1C), // Green
    Color(0xFFBA1A1A), // Red
    Color(0xFF8B5000), // Orange
    Color(0xFF006B5F), // Teal
    Color(0xFF984061), // Pink
    Color(0xFF5D5F5F), // Grey
    Color(0xFF4758A9), // Indigo
    Color(0xFF7D5260), // Rose
    Color(0xFF006874), // Cyan
    Color(0xFF5C6300), // Lime
  ];

  // --- Light Theme ---
  static const Color lightBackground = Color(0xFFFFFBFF);
  static const Color lightSurface = Color(0xFFFFFBFF);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EB);
  static const Color lightOnBackground = Color(0xFF1C1B1F);
  static const Color lightOnSurface = Color(0xFF1C1B1F);
  static const Color lightOnSurfaceVariant = Color(0xFF49454E);
  static const Color lightOutline = Color(0xFF7A757F);

  // --- Dark Theme ---
  static const Color darkBackground = Color(0xFF1C1B1F);
  static const Color darkSurface = Color(0xFF1C1B1F);
  static const Color darkSurfaceVariant = Color(0xFF49454E);
  static const Color darkOnBackground = Color(0xFFE6E1E6);
  static const Color darkOnSurface = Color(0xFFE6E1E6);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4CF);
  static const Color darkOutline = Color(0xFF948F99);

  // --- AMOLED Theme ---
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF0A0A0A);
  static const Color amoledSurfaceVariant = Color(0xFF1A1A1A);
  static const Color amoledOnBackground = Color(0xFFE6E1E6);
  static const Color amoledOnSurface = Color(0xFFE6E1E6);

  // --- Player ---
  static const Color playerOverlay = Color(0x80000000);
  static const Color shimmerBase = Color(0xFF2A2A2A);
  static const Color shimmerHighlight = Color(0xFF3A3A3A);

  // --- Glassmorphism ---
  static const Color glassLight = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x33000000);
  static const Color glassBorder = Color(0x22FFFFFF);
}
