// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async'; // Add this for runZonedGuarded
import 'db/country_adapter.dart';
import 'screens/home_screen.dart';
import 'screens/error_screen.dart';
import 'utils/error_reporter.dart';

// Global key for showing snackbars from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      ErrorReporter.reportError(details.exception, details.stack);
    };

    try {
      await initializeApp();
      runApp(const MyApp());
    } catch (error, stackTrace) {
      ErrorReporter.reportError(error, stackTrace);
      runApp(ErrorApp(error: error.toString()));
    }
  }, (error, stackTrace) {
    // Catch errors that happen outside of the Flutter framework
    ErrorReporter.reportError(error, stackTrace);
  });
}

Future<void> initializeApp() async {
  try {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(CountryVisitAdapter().typeId)) {
      Hive.registerAdapter(CountryVisitAdapter());
    }
    
    await Hive.openBox<CountryVisit>('country_visits');
  } catch (e, stackTrace) {
    throw AppInitializationException('Failed to initialize app: $e', stackTrace);
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

class AppInitializationException implements Exception {
  final String message;
  final StackTrace stackTrace;

  AppInitializationException(this.message, this.stackTrace);

  @override
  String toString() => message;
}