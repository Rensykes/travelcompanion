import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:async';
import 'db/country_adapter.dart';
import 'db/location_log.dart';
import 'screens/home_screen.dart';
import 'screens/error_screen.dart';
import 'services/location_service.dart';
import 'services/country_service.dart';
import 'services/log_service.dart';
import 'utils/hive_constants.dart';
import 'utils/error_reporter.dart';

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
  if (!Hive.isAdapterRegistered(LocationLogAdapter().typeId)) {
    Hive.registerAdapter(LocationLogAdapter());
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

/// This is useful to prevent issues where the app crashes because a box is accessed before being opened.
Future<void> initializeApp() async {
  try {
    if (!Hive.isBoxOpen(countryVisitsBoxName)) {
      var countryVisitsBox = await Hive.openBox<CountryVisit>(
        countryVisitsBoxName,
      );
      await countryVisitsBox
          .close(); // Ensure the box is closed after initialization
    }
    if (!Hive.isBoxOpen(locationLogsBoxName)) {
      var locationLogBox = await Hive.openBox<LocationLog>(locationLogsBoxName);
      await locationLogBox
          .close(); // Ensure the box is closed after initialization
    }
  } catch (e, stackTrace) {
    throw AppInitializationException(
      'Failed to initialize app: $e',
      stackTrace,
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      DartPluginRegistrant.ensureInitialized();

      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(LocationLogAdapter().typeId)) {
        Hive.registerAdapter(LocationLogAdapter());
      }
            if (!Hive.isAdapterRegistered(CountryVisitAdapter().typeId)) {
        Hive.registerAdapter(CountryVisitAdapter());
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        forceAndroidLocationManager:
            true, // This is important. [FusedLocationProviderClient] does not seem to work
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String? placemark = placemarks.first.isoCountryCode;

      if (placemark != null) {
        await CountryService.saveCountryVisit(placemark);

        // ✅ Use LogService to log success
        await LogService.logEntry(status: "success", countryCode: placemark);
        log("✅ Background Task Success: Country - $placemark");
      } else {
        // ❌ Use LogService to log failure
        await LogService.logEntry(status: "error");
        log("❌ Background Task Failed: No country detected");
      }
    } catch (e) {
      log("❌ Background Task Failed $e");
      return Future.value(false);
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
