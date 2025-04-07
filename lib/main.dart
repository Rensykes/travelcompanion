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

Future main() async {
  // Initialize error handling - pass null for context since app hasn't started
  initializeErrorHandling(null);

  try {
    // Initialize configuration based on build flavor
    await AppConfig().initialize();

    // Configure error reporting based on environment
    if (AppConfig().enableLogs) {
      // TODO: Initialize logging service here if needed
    }

    runApp(const ProviderScope(child: MyApp()));
  } catch (error, stackTrace) {
    // Pass null for context since we don't have a valid context yet
    ErrorReporter.reportError(null, error, stackTrace);
    runApp(ErrorApp(error: error.toString()));
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> {
  // This will be called when theme is changed in Settings
  void _handleThemeChanged(bool isDark, bool useSystemTheme) {
    ref
        .read(themePreferencesProvider.notifier)
        .setThemeMode(isDarkMode: isDark, useSystemTheme: useSystemTheme);
  }

  @override
  Widget build(BuildContext context) {
    // Watch theme preferences
    final themePrefsAsync = ref.watch(themePreferencesProvider);

    // Get app name from config
    final appName = AppConfig().appName;

    // Add a visual indicator of environment in non-prod builds
    String titlePrefix = '';
    if (AppConfig().environment != Environment.prod) {
      titlePrefix = '[${AppConfig().environment.name.toUpperCase()}] ';
    }

    return themePrefsAsync.when(
      data: (themePrefs) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner:
              AppConfig().environment != Environment.prod,
          title: '$titlePrefix$appName',
          themeMode:
              themePrefs.useSystemTheme
                  ? ThemeMode.system
                  : (themePrefs.isDarkMode ? ThemeMode.dark : ThemeMode.light),
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          home: HomeScreen(
            onThemeChanged: _handleThemeChanged,
            isDarkMode: themePrefs.isDarkMode,
            useSystemTheme: themePrefs.useSystemTheme,
          ),
          builder: (context, child) {
            return child ?? const SizedBox.shrink();
          },
        );
      },
      loading:
          () => MaterialApp(
            theme: AppThemes.lightTheme,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ),
      error:
          (error, stack) => MaterialApp(
            theme: AppThemes.lightTheme,
            home: ErrorScreen(error: error.toString()),
          ),
    );
  }
}
