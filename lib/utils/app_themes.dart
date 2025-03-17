import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.pink,
    secondaryHeaderColor: Colors.pink,
    hintColor: Colors.pink,
    colorScheme: ColorScheme.light(
      primary: Colors.pink,
      secondary: Colors.pinkAccent,
    ),
    buttonTheme: const ButtonThemeData(buttonColor: Colors.pink),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.pink,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
    ),
    // Add more light theme customizations here
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueAccent,
    secondaryHeaderColor: Colors.blueAccent,
    hintColor: Colors.blueAccent,
    colorScheme: ColorScheme.dark(
      primary: Colors.blueAccent,
      secondary: Colors.blue,
    ),
    buttonTheme: const ButtonThemeData(buttonColor: Colors.blueAccent),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
    ),
    // Add more dark theme customizations here
  );
}