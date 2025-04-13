import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/presentation/bloc/theme/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the application's theme preferences.
///
/// This cubit handles loading, saving, and changing theme settings.
/// It supports three modes:
/// - Light theme
/// - Dark theme
/// - System theme (follows the device settings)
///
/// Theme settings are persisted between app sessions using SharedPreferences.
class ThemeCubit extends Cubit<ThemeState> {
  /// Key for storing the theme mode preference (light/dark)
  static const String themePreferenceKey = 'theme_mode';

  /// Key for storing whether to use system theme preference
  static const String useSystemThemeKey = 'use_system_theme';

  /// Creates a ThemeCubit instance.
  ///
  /// Immediately loads the saved theme preferences.
  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }

  /// Loads the saved theme preferences from SharedPreferences.
  ///
  /// First checks if the user has chosen to use the system theme.
  /// If not, loads the specific theme preference (light or dark).
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

  /// Sets whether to use the system theme.
  ///
  /// When enabled, the app will follow the device's theme settings.
  /// When disabled, the app will use the explicitly set theme preference.
  ///
  /// Parameters:
  /// - [useSystemTheme]: True to use system theme, false to use explicit setting
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

  /// Sets the explicit dark/light theme preference.
  ///
  /// This also disables the system theme option since the user is
  /// explicitly choosing a theme.
  ///
  /// Parameters:
  /// - [isDarkMode]: True to use dark theme, false to use light theme
  Future<void> setDarkMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themePreferenceKey, isDarkMode);

    final themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    emit(ThemeState(themeMode: themeMode));
  }

  /// Whether the current theme setting is to use the system theme
  bool get useSystemTheme => state.themeMode == ThemeMode.system;

  /// Whether the current theme setting is dark mode
  bool get isDarkMode => state.themeMode == ThemeMode.dark;
}
