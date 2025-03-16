import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location_tracker/utils/app_initializer.dart';
import 'screens/home_screen.dart';
import 'screens/error_screen.dart';
import 'utils/error_reporter.dart';
import 'utils/error_handling.dart';
import 'scheduler/background_task.dart';

// Global key for showing snackbars from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Travel Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
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