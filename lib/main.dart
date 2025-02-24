import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:async';
import 'db/country_adapter.dart';
import 'screens/home_screen.dart';
import 'screens/error_screen.dart';
import 'utils/error_reporter.dart';
import 'services/location_service.dart';
import 'services/country_service.dart';

// Global key for showing snackbars from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const fetchLocationInBackgroundTask = "fetchLocationInBackgroundTask";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    ErrorReporter.reportError(details.exception, details.stack);
  };

  // Initialize Hive
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(CountryVisitAdapter().typeId)) {
    Hive.registerAdapter(CountryVisitAdapter());
  }

  // Initialize Workmanager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "1",
    fetchLocationInBackgroundTask,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep, // Avoid multiple instances
  );

  try {
    await initializeApp();
    runApp(const MyApp());
  } catch (error, stackTrace) {
    ErrorReporter.reportError(error, stackTrace);
    runApp(ErrorApp(error: error.toString()));
  }
}

Future<void> initializeApp() async {
  try {
    if (!Hive.isBoxOpen('country_visits')) {
      var box = await Hive.openBox<CountryVisit>('country_visits');
      await box.close(); // Ensure the box is closed after initialization
    }
  } catch (e, stackTrace) {
    throw AppInitializationException('Failed to initialize app: $e', stackTrace);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter services are available

    if (task == fetchLocationInBackgroundTask) {
      try {
        await Hive.initFlutter();
        if (!Hive.isAdapterRegistered(CountryVisitAdapter().typeId)) {
          Hive.registerAdapter(CountryVisitAdapter());
        }

        bool hasPermission = await LocationService.requestPermission();
        if (!hasPermission) {
          print("Location permission denied in background task.");
          return Future.value(false);
        }

        String? country = await LocationService.getCurrentCountry();
        if (country != null) {
          await CountryService.saveCountryVisit(country);
          print("Saved country visit: $country");
        }
      } catch (e, stackTrace) {
        ErrorReporter.reportError(e, stackTrace);
        print("Error fetching location in background: $e");
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
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
