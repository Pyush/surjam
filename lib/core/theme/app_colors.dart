import 'package:flutter/material.dart';

class AppColors {
  // Brand Gradients & Dark Backgrounds
  static const Color darkBackground = Color(0xFF0F0E17);
  static const Color darkCard = Color(0xFF1B1A27);
  static const Color darkCardBorder = Color(0xFF2E2D45);
  
  static const Color primaryNeon = Color(0xFFFF8906); // Warm Amber Gold
  static const Color primaryCyan = Color(0xFF00E5FF); // Electric Cyan
  static const Color accentMagenta = Color(0xFFE53170); // Deep Rose/Magenta
  static const Color accentPurple = Color(0xFF7F5AF0); // Royal Indigo
  
  // Instrument Theme Colors
  static const Color pianoGold = Color(0xFFFFB703);
  static const Color tablaAmber = Color(0xFFFB8500);
  static const Color learnGreen = Color(0xFF2CB67D);
  static const Color recordRed = Color(0xFFE63946);

  // Piano Key Colors
  static const Color whiteKeyNormal = Color(0xFFF8F9FA);
  static const Color whiteKeyPressed = Color(0xFFDCDFE5);
  static const Color whiteKeyHighlight = Color(0xFFA7F3D0); // Learn mode target
  
  static const Color blackKeyNormal = Color(0xFF16161A);
  static const Color blackKeyPressed = Color(0xFF33272A);
  static const Color blackKeyHighlight = Color(0xFF059669);

  // Glassmorphism overlays
  static Color glassBorder = Colors.white.withValues(alpha: 0.12);
  static Color glassBackground = const Color(0xFF222034).withValues(alpha: 0.7);
  
  // Text & Neutral
  static const Color textPrimary = Color(0xFFFFFFFE);
  static const Color textSecondary = Color(0xFF94A1B2);
  static const Color textMuted = Color(0xFF72757E);
}
