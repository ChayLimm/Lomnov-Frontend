import 'package:flutter/material.dart';
import 'text_styles.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      textTheme: TextStyles.textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // Enhanced Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor ?? Colors.blue,
        brightness: Brightness.light,
      ).copyWith(
        error: AppColors.errorColor,
        surface: AppColors.surfaceColor,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 1,
      ),
    );
  }
  
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: TextStyles.textTheme.apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // Enhanced Color Scheme for Dark
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor ?? Colors.blue,
        brightness: Brightness.dark,
      ).copyWith(
        error: AppColors.errorColor,
        surface: AppColors.darkSurface,
      ),
      
      // Card Theme for Dark
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),
      
      // AppBar Theme for Dark
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
    );
  }
}
