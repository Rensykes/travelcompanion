import 'dart:developer';
import 'dart:ui';
import 'package:trackie/application/services/sim_info_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';

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

      // Create repository instances
      final countryVisitsRepository = CountryVisitsRepository(
        backgroundDatabase,
      );
      final locationLogsRepository = LocationLogsRepository(backgroundDatabase);

      String? isoCode = await SimInfoService.getIsoCode();

      if (isoCode != null) {
        // Use instance methods
        await countryVisitsRepository.saveCountryVisit(isoCode);

        // Use LogService instance to log success
        await locationLogsRepository.logEntry(
          status: "success",
          countryCode: isoCode,
        );
        DateTime dateTime = DateTime.now();
        log("✅ Background Task Success: Country - $isoCode - $dateTime");
      } else {
        // Use LogService instance to log failure
        await locationLogsRepository.logEntry(status: "error");
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

void initializeWorkmanager(bool bool, {required bool isInDebugMode}) {
  log("Initializing Workmanager - debug: $bool");
  Workmanager().initialize(callbackDispatcher, isInDebugMode: isInDebugMode);
  Workmanager().registerPeriodicTask(
    "1",
    fetchLocationInBackgroundTask,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep, // Avoid multiple instances
  );
}
