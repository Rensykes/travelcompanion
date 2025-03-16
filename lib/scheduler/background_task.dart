import 'dart:developer';
import 'dart:ui';
import 'package:workmanager/workmanager.dart';
import '../../database/database.dart';
import '../services/location_service.dart';
import '../repositories/country_visits.dart';
import '../repositories/location_logs.dart';

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
      
      // Create service instances
      final countryService = CountryVisitsRepository(backgroundDatabase);
      final logService = LocationLogsRepository(backgroundDatabase);

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