import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/presentation/bloc/theme/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String themePreferenceKey = 'theme_mode';
  static const String useSystemThemeKey = 'use_system_theme';

  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final useSystemTheme = prefs.getBool(useSystemThemeKey) ?? true;

    if (useSystemTheme) {
      emit(const ThemeState(themeMode: ThemeMode.system));
    } else {
      final isDarkMode = prefs.getBool(themePreferenceKey) ?? false;
      final themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      emit(ThemeState(themeMode: themeMode));
    }
  }

  Future<void> setUseSystemTheme(bool useSystemTheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(useSystemThemeKey, useSystemTheme);

    if (useSystemTheme) {
      emit(const ThemeState(themeMode: ThemeMode.system));
    } else {
      // If not using system theme, use the saved theme or default to light
      final isDarkMode = prefs.getBool(themePreferenceKey) ?? false;
      final themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      emit(ThemeState(themeMode: themeMode));
    }
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themePreferenceKey, isDarkMode);

    final themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    emit(ThemeState(themeMode: themeMode));
  }

  bool get useSystemTheme => state.themeMode == ThemeMode.system;
  bool get isDarkMode => state.themeMode == ThemeMode.dark;
}
