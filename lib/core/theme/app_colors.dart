import 'package:flutter/material.dart';

/// Semantic and cohesive color tokens for ShopSphere.
class AppColors {
  AppColors._();

  // Primary brand palette (Deep Indigo)
  static const Color primary = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF312E81);

  // Secondary accent (Warm Slate / Neutral Accent)
  static const Color secondary = Color(0xFF475569);
  static const Color secondaryLight = Color(0xFF64748B);
  static const Color secondaryDark = Color(0xFF1E293B);

  // Success / Rating / Discount
  static const Color success = Color(0xFF15803D);
  static const Color discount = Color(0xFF15803D);
  static const Color discountBadge = Color(0xFFDC2626);
  static const Color rating = Color(0xFFF59E0B);

  // Neutral Colors (Light mode)
  static const Color backgroundLight = Color(0xFFF8F7F4);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF191927);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE7E5E4);

  // Neutral Colors (Dark mode)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Error
  static const Color error = Color(0xFFB91C1C);
  static const Color onError = Color(0xFFFFFFFF);
}
