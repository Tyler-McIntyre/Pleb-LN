import 'package:flutter/material.dart';

/// Application color palette
/// 
/// Centralized color definitions for consistent theming throughout the app
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color black = Colors.black;
  static const Color black2 = Color.fromARGB(185, 42, 49, 43);
  static const Color white = Color(0xffF2FCF3);
  static const Color blue = Color(0xff1985A1);
  
  // Accent Colors
  static const Color green = Color(0xff388A4B);
  static const Color lightGreen = Colors.green;
  static const Color red = Color.fromARGB(255, 245, 22, 37);
  static const Color purple = Colors.purple;
  
  // Neutral Colors
  static const Color background = Color(0xffDCDCDD);
  static const Color grey = Color(0xffC5C3C6);
  static const Color jet = Color.fromARGB(90, 70, 73, 76);
  static const Color darkBlue = Color(0xff4C5C68);

  // Semantic Colors
  static const Color success = green;
  static const Color error = red;
  static const Color warning = Color(0xffFF9500);
  static const Color info = blue;

  // Bitcoin Colors
  static const Color bitcoin = Color(0xffF7931A);
  static const Color lightning = Color(0xffFFD700);

  // Helper method to get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Helper method to get a lighter shade of a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  // Helper method to get a darker shade of a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
