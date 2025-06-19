import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primaryColor = Color(0xFF6E5DE7); // Purple color from design
  static const accentColor = Color(0xFF5C5CFF);
  static const backgroundColor = Color(0xFFF9F9F9);
  static const cardColor = Colors.white;
  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF666666);
  static const textTertiary = Color(0xFF999999);
  static const errorColor = Color(0xFFE53935);
  static const successColor = Color(0xFF43A047);
  
  // Specialty colors
  static const neurologistColor = Color(0xFFFFC2C2); // Light red for brain icon
  static const cardiologistColor = Color(0xFFC2E8FF); // Light blue for heart icon
  static const orthopedistColor = Color(0xFFFFE2C2); // Light orange for bone icon
  static const pulmonologistColor = Color(0xFFD1C2FF); // Light purple for lung icon
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
        error: AppColors.errorColor,
        surface: AppColors.cardColor,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        color: AppColors.cardColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textTertiary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
