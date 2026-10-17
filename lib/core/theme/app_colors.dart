import 'package:flutter/material.dart';

/// Semantic and cohesive color tokens for ShopSphere.
class AppColors {
  AppColors._();

  // Primary brand palette (Modern Royal Indigo)
  static const Color primary = Color(0xFF3F51B5);
  static const Color primaryLight = Color(0xFF757DE8);
  static const Color primaryDark = Color(0xFF002984);

  // Secondary accent (Vibrant Coral / Amber)
  static const Color secondary = Color(0xFFFF6D00);
  static const Color secondaryLight = Color(0xFFFF9E40);
  static const Color secondaryDark = Color(0xFFC43E00);

  // Success / Rating / Discount
  static const Color success = Color(0xFF2E7D32);
  static const Color discount = Color(0xFFD32F2F);
  static const Color rating = Color(0xFFFFA000);

  // Neutral Colors (Light mode)
  static const Color backgroundLight = Color(0xFFF8F9FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1C1E);
  static const Color textSecondaryLight = Color(0xFF74777F);
  static const Color borderLight = Color(0xFFE2E4E9);

  // Neutral Colors (Dark mode)
  static const Color backgroundDark = Color(0xFF111318);
  static const Color surfaceDark = Color(0xFF191C22);
  static const Color cardDark = Color(0xFF21252D);
  static const Color textPrimaryDark = Color(0xFFE2E2E6);
  static const Color textSecondaryDark = Color(0xFF8E9099);
  static const Color borderDark = Color(0xFF2E313A);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
}
