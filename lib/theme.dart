import 'package:flutter/material.dart';

class AppColors {
  static const Color lightPeach = Color(0xFFFFB894);
  static const Color softPink = Color(0xFFFB9590);
  static const Color roseRed = Color(0xFFDC586D);
  static const Color darkRose = Color(0xFFA33757);
  static const Color wineRed = Color(0xFF852E4E);
  static const Color deepPlum = Color(0xFF4C1D3D);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.roseRed,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: AppColors.roseRed,
      secondary: AppColors.softPink,
      background: AppColors.lightPeach,
      surface: AppColors.darkRose,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.roseRed,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: AppColors.deepPlum,
        fontWeight: FontWeight.bold,
      ),
      bodyMedium: TextStyle(color: AppColors.darkRose, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.wineRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.roseRed,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.deepPlum,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.wineRed,
      secondary: AppColors.roseRed,
      background: AppColors.deepPlum,
      surface: AppColors.darkRose,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.deepPlum,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.roseRed,
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.wineRed,
      foregroundColor: Colors.white,
    ),
  );
}
