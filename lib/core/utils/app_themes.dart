import 'package:flutter/material.dart';

class AppThemes {
  // Color constants
  static const Color primaryGreen = Color(0xFF3E7D32); // Forest Green
  static const Color accentGreen = Color(0xFF81C784); // Light Green
  static const Color darkGreen = Color(0xFF2E5F24); // Dark Forest Green
  static const Color lightGreen = Color(0xFFE7F0DC); // Very Light Green
  static const Color contrastBrown = Color(0xFF795548); // Brown for contrast

  // Light Theme
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    secondaryHeaderColor: darkGreen,
    hintColor: accentGreen,
    scaffoldBackgroundColor: lightGreen,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: accentGreen,
      tertiary: contrastBrown,
      onPrimary: Colors.white,
      onSecondary: Colors.black87,
    ),
    buttonTheme: const ButtonThemeData(buttonColor: primaryGreen),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkGreen,
      ),
    ),
    iconTheme: const IconThemeData(
      color: primaryGreen,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),
  );

  // Dark Theme
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF1F452A), // Darker Forest Green
    secondaryHeaderColor: Color(0xFF1F452A),
    hintColor: Color(0xFF5A9E6F), // Medium Green
    scaffoldBackgroundColor: Color(0xFF121212), // Dark Background
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1F452A), // Darker Forest Green
      secondary: Color(0xFF5A9E6F), // Medium Green
      tertiary: Color(0xFF91694F), // Darker Brown for contrast
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      surface: Color(0xFF1D1D1D), // Slightly lighter than background
      background: Color(0xFF121212), // Dark Background
    ),
    buttonTheme: const ButtonThemeData(buttonColor: Color(0xFF1F452A)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1D1D1D),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1F452A),
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Color(0xFF5A9E6F),
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF5A9E6F),
    ),
    cardTheme: CardTheme(
      color: Color(0xFF252525),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1F452A),
      foregroundColor: Colors.white,
    ),
  );
}
