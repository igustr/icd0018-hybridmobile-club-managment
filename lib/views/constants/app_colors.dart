import 'package:flutter/material.dart';

@immutable
class AppColors {
  const AppColors._();

  // Main colours
  static const Color primaryBlue = Color(0xFF0033A0);
  static const Color lightBlue = Color(0xFF007BFF);
  static const Color skyBlue = Color(0xFFB3E5FC);

  // Neutral
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color darkGrey = Color(0xFF121212);
  static const Color grey = Color(0xFF9E9E9E);

  // Errors and success
  static const Color accentGold = Color(0xFFFEDA75);
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF43A047);

  // Buttons and text
  static const Color loginButtonColor = accentGold;
  static const Color loginButtonTextColor = black;
}
