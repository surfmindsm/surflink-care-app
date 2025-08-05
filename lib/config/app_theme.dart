import 'package:flutter/material.dart';
import 'app_config.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(AppConfig.primaryColor),
        brightness: Brightness.light,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Color(AppConfig.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.cardRadius),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConfig.defaultPadding,
          vertical: 8,
        ),
      ),
      
      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppConfig.primaryColor),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // OutlinedButton Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(AppConfig.primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
          ),
          side: BorderSide(color: Color(AppConfig.primaryColor)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // TextButton Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Color(AppConfig.primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // InputDecoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
          borderSide: BorderSide(color: Color(AppConfig.primaryColor)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.buttonRadius),
          borderSide: BorderSide(color: Color(AppConfig.errorColor)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: Color(AppConfig.primaryColor),
        size: 24,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(AppConfig.primaryColor),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Colors.grey,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(AppConfig.primaryColor),
        brightness: Brightness.dark,
      ),
      
      // Similar configurations for dark theme
      appBarTheme: AppBarTheme(
        backgroundColor: Color(AppConfig.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
