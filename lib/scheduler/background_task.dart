import 'dart:developer';
import 'dart:ui';
import 'package:trackie/utils/location_permission_manager.dart';
import 'package:workmanager/workmanager.dart';
import 'package:trackie/database/database.dart';
import 'package:trackie/services/location_service.dart';
import 'package:trackie/repositories/country_visits.dart';
import 'package:trackie/repositories/location_logs.dart';

const fetchLocationInBackgroundTask = "fetchLocationInBackgroundTask";

// Singleton instance of the database for background tasks
late AppDatabase backgroundDatabase;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      DartPluginRegistrant.ensureInitialized();

      // Initialize database for background task
      backgroundDatabase = AppDatabase();
      
      // Create log service instance for logging regardless of permission state
      final logService = LocationLogsRepository(backgroundDatabase);
      
      // Check if "Always" location permission is granted
      bool hasAlwaysPermission = await LocationPermissionManager.hasAlwaysLocationPermission();
      
      if (!hasAlwaysPermission) {
        // Log that task was skipped due to permission and exit early
        await logService.logEntry(status: "skipped");
        log("⚠️ Background Task Skipped: 'Always' location permission not granted");
        await backgroundDatabase.close();
        return Future.value(true); // Task completed successfully (by skipping)
      }

      // Continue with normal operation since we have permission
      final countryService = CountryVisitsRepository(backgroundDatabase);

      String? placemark = await LocationService.getCurrentCountry();

      if (placemark != null) {
        // Use instance methods
        await countryService.saveCountryVisit(placemark);

        // Use LogService instance to log success
        await logService.logEntry(status: "success", countryCode: placemark);
        DateTime dateTime = DateTime.now();
        log("✅ Background Task Success: Country - $placemark - $dateTime");
      } else {
        // Use LogService instance to log failure
        await logService.logEntry(status: "error");
        log("❌ Background Task Failed: No country detected");
      }
      
      // Close the database to prevent memory leaks
      await backgroundDatabase.close();
    } catch (e) {
      log("❌ Background Task Failed $e");
      return Future.value(false);
    }
    return Future.value(true);
  });
}

void initializeWorkmanager() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "1",
    fetchLocationInBackgroundTask,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep, // Avoid multiple instances
  );
}