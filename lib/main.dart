import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/core/utils/app_themes.dart';
import 'package:trackie/presentation/screens/home_screen.dart';
import 'package:trackie/presentation/screens/error_screen.dart';
import 'package:trackie/core/error/error_reporter.dart';
import 'package:trackie/core/error/error_handling.dart';
import 'package:trackie/core/scheduler/background_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global key for showing snackbars from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling - pass null for context since app hasn't started
  initializeErrorHandling(null);

  try {
    // Initialize Workmanager for background tasks
    initializeWorkmanager();

    runApp(ProviderScope(child: MyApp()));
  } catch (error, stackTrace) {
    // Pass null for context since we don't have a valid context yet
    ErrorReporter.reportError(null, error, stackTrace);
    runApp(ErrorApp(error: error.toString()));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _useSystemTheme = false;

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  // Load theme settings from SharedPreferences
  void _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useSystemTheme = prefs.getBool('useSystemTheme') ?? false;
      _isDarkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  // Save theme settings to SharedPreferences
  void _saveThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('useSystemTheme', _useSystemTheme);
    prefs.setBool('darkMode', _isDarkMode);
  }

  // Handle theme changed callback from HomeScreen
  void _handleThemeChanged(bool isDark, bool useSystemTheme) {
    setState(() {
      _isDarkMode = isDark;
      _useSystemTheme = useSystemTheme;
      _saveThemeSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Travel Tracker',
      themeMode:
          _useSystemTheme
              ? ThemeMode.system
              : (_isDarkMode ? ThemeMode.dark : ThemeMode.light),
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: HomeScreen(
        onThemeChanged: _handleThemeChanged,
        isDarkMode: _isDarkMode,
        useSystemTheme: _useSystemTheme,
      ),
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ErrorScreen(error: error),
    );
  }
}
