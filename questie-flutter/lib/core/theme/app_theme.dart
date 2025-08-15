import 'package:flutter/material.dart';

class AppTheme {
  // Calming color palette inspired by nature and wellness
  static const Color primaryGreen = Color(0xFF6B8E6B);
  static const Color lightGreen = Color(0xFFE8F5E8);
  static const Color accentBlue = Color(0xFF7BA7BC);
  static const Color softPeach = Color(0xFFFDF2E9);
  static const Color warmWhite = Color(0xFFFFFDF8);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color mediumGray = Color(0xFFE9ECEF);
  static const Color darkGray = Color(0xFF495057);

  // Calm Mode colors - even softer and more muted
  static const Color calmPrimary = Color(0xFF8FA68F);
  static const Color calmBackground = Color(0xFFF8FBF8);
  static const Color calmSurface = Color(0xFFF0F8F0);
  static const Color calmAccent = Color(0xFFB8D4B8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        surface: warmWhite,
        primary: primaryGreen,
        secondary: accentBlue,
        tertiary: softPeach,
      ),
      scaffoldBackgroundColor: warmWhite,
      // fontFamily: 'Inter', // Commented out until fonts are added
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGray,
          // fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: darkGray),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: mediumGray.withValues(alpha: 0.3), width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            // fontFamily: 'Inter',
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            // fontFamily: 'Inter',
          ),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: mediumGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          // fontFamily: 'Inter',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          // fontFamily: 'Inter',
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        primary: lightGreen,
        secondary: accentBlue,
        tertiary: softPeach,
      ),
      // fontFamily: 'Inter',
    );
  }

  // Calm Mode theme with softer colors and more spacing
  static ThemeData getCalmTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: calmPrimary,
        surface: calmSurface,
        secondary: calmAccent,
      ),
      scaffoldBackgroundColor: calmBackground,
      cardTheme: baseTheme.cardTheme.copyWith(
        color: calmSurface,
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), // More spacing
      ),
    );
  }
}
