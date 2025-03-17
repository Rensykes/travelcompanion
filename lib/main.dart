import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trackie/utils/app_initializer.dart';
import 'package:trackie/utils/app_themes.dart';
import 'package:trackie/screens/home_screen.dart';
import 'package:trackie/screens/error_screen.dart';
import 'package:trackie/utils/error_reporter.dart';
import 'package:trackie/utils/error_handling.dart';
import 'package:trackie/scheduler/background_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global key for showing snackbars from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling
  initializeErrorHandling();

  try {
    // Initialize database
    await initializeApp();
    
    // Initialize Workmanager for background tasks
    initializeWorkmanager();
    
    runApp(const MyApp());
  } catch (error, stackTrace) {
    ErrorReporter.reportError(error, stackTrace);
    runApp(ErrorApp(error: error.toString()));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      themeMode: _useSystemTheme
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