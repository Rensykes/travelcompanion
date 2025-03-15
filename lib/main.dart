import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db/country_adapter.dart';
import 'db/location_log.dart';
import 'screens/home_screen.dart';
import 'screens/error_screen.dart';
import 'utils/error_reporter.dart';
import 'error_handling.dart';
import 'app_initializer.dart';
import 'background_task.dart';

// Global key for showing snackbars from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling
  initializeErrorHandling();

  // Initialize Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(CountryVisitAdapter().typeId)) {
    Hive.registerAdapter(CountryVisitAdapter());
  }
  if (!Hive.isAdapterRegistered(LocationLogAdapter().typeId)) {
    Hive.registerAdapter(LocationLogAdapter());
  }

  // Initialize Workmanager
  initializeWorkmanager();

  try {
    await initializeApp();
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
