import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0D1117);
  static const Color surface    = Color(0xFF161B22);
  static const Color card       = Color(0xFF1C2433);
  static const Color cardLight  = Color(0xFF21293A);

  // Greens (primary brand)
  static const Color primary     = Color(0xFF00C853);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryMid  = Color(0xFF00897B);
  static const Color accent      = Color(0xFF69F0AE);

  // Text
  static const Color textPrimary   = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted     = Color(0xFF484F58);

  // Meal type colours
  static const Color breakfast = Color(0xFFFF9A3C);
  static const Color lunch     = Color(0xFF4ECDC4);
  static const Color dinner    = Color(0xFFA78BFA);
  static const Color snack     = Color(0xFFF9CA24);

  // Status
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFB300);
  static const Color error   = Color(0xFFEF5350);
  static const Color info    = Color(0xFF42A5F5);

  // Chart
  static const Color chartProtein = Color(0xFF42A5F5);
  static const Color chartCarbs   = Color(0xFFFF7043);
  static const Color chartFat     = Color(0xFFAB47BC);

  // Divider
  static const Color divider = Color(0xFF30363D);

  static Color mealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast': return breakfast;
      case 'lunch':     return lunch;
      case 'dinner':    return dinner;
      default:          return snack;
    }
  }
}
