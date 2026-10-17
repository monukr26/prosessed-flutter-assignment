import 'package:flutter/widgets.dart';

/// Application-wide UI layout and timing constants.
class AppConstants {
  AppConstants._();

  // Responsive Breakpoints
  static const double compactBreakpoint = 600.0;
  static const double mediumBreakpoint = 1024.0;

  // Search debounce duration
  static const Duration searchDebounce = Duration(milliseconds: 400);

  // Spacing Scale
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Touch Target Minimum
  static const double minTouchTarget = 48.0;

  // Helpers for responsive layout checks
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactBreakpoint;

  static bool isMedium(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compactBreakpoint && width <= mediumBreakpoint;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width > mediumBreakpoint;
}
