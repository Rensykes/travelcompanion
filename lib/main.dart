import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/core/utils/app_themes.dart';
import 'package:trackie/error_app.dart';
import 'package:trackie/presentation/screens/home_screen.dart';
import 'package:trackie/presentation/screens/error_screen.dart';
import 'package:trackie/core/error/error_reporter.dart';
import 'package:trackie/core/error/error_handling.dart';
import 'package:trackie/presentation/providers/theme_preferences_provider.dart';
import 'package:trackie/core/config/app_config.dart';

// Global key for showing snackbars from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Application entry point
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling before anything else
  initializeErrorHandling(null);

  try {
    // Initialize app configuration based on build flavor
    await _initializeApp();

    // Start the application
    runApp(const ProviderScope(child: MyApp()));
  } catch (error, stackTrace) {
    ErrorReporter.reportError(null, error, stackTrace);
    runApp(ErrorApp(error: error.toString()));
  }
}

/// Initialize all app dependencies
Future<void> _initializeApp() async {
  // Initialize configuration based on build flavor
  await AppConfig().initialize();

  // Configure error reporting based on environment
  if (AppConfig().enableLogs) {
    // Initialize logging service
    await _initializeLogging();
  }
}

/// Initialize logging services
Future<void> _initializeLogging() async {
  // TODO: Initialize logging service here
}

/// Main application widget
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme preferences
    final themePrefsAsync = ref.watch(themePreferencesProvider);

    return themePrefsAsync.when(
      data: (themePrefs) => _buildApp(themePrefs, ref),
      loading: () => _buildLoadingApp(),
      error: (error, stack) => _buildErrorApp(error),
    );
  }

  /// Build the main application with loaded theme preferences
  MaterialApp _buildApp(ThemePreferencesState themePrefs, WidgetRef ref) {
    // Get app name from config
    final appName = AppConfig().appName;
    final environment = AppConfig().environment;

    // Add a visual indicator of environment in non-prod builds
    final String titlePrefix =
        environment != Environment.prod
            ? '[${environment.name.toUpperCase()}] '
            : '';

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: environment != Environment.prod,
      title: '$titlePrefix$appName',
      themeMode: _determineThemeMode(themePrefs),
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: HomeScreen(
        onThemeChanged:
            (isDark, useSystemTheme) =>
                _handleThemeChanged(ref, isDark, useSystemTheme),
        isDarkMode: themePrefs.isDarkMode,
        useSystemTheme: themePrefs.useSystemTheme,
      ),
      builder: (context, child) => child ?? const SizedBox.shrink(),
    );
  }

  /// Build a loading screen while theme preferences are loading
  MaterialApp _buildLoadingApp() {
    return MaterialApp(
      theme: AppThemes.lightTheme,
      home: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  /// Build an error screen if theme preferences loading fails
  MaterialApp _buildErrorApp(Object error) {
    return MaterialApp(
      theme: AppThemes.lightTheme,
      home: ErrorScreen(error: error.toString()),
    );
  }

  /// Determine the theme mode based on preferences
  ThemeMode _determineThemeMode(ThemePreferencesState prefs) {
    if (prefs.useSystemTheme) return ThemeMode.system;
    return prefs.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  /// Theme change handler for passing to HomeScreen
  void _handleThemeChanged(WidgetRef ref, bool isDark, bool useSystemTheme) {
    ref
        .read(themePreferencesProvider.notifier)
        .setThemeMode(isDarkMode: isDark, useSystemTheme: useSystemTheme);
  }
}
