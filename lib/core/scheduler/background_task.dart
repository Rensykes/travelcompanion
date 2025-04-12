import 'dart:developer';
import 'dart:ui';
import 'package:trackie/application/services/sim_info_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/data/repositories/log_country_relations_repository.dart';
import 'package:trackie/application/services/location_service.dart';

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
      final countryVisitsRepository =
          CountryVisitsRepository(backgroundDatabase);
      final locationLogsRepository = LocationLogsRepository(backgroundDatabase);
      final logCountryRelationsRepository =
          LogCountryRelationsRepository(backgroundDatabase);

      // Create service using repositories
      final locationService = LocationService(
        locationLogsRepository: locationLogsRepository,
        countryVisitsRepository: countryVisitsRepository,
        logCountryRelationsRepository: logCountryRelationsRepository,
      );

      String? isoCode = await SimInfoService.getIsoCode();

      if (isoCode != null) {
        // Use the service to log the entry, which will handle all the complex logic
        await locationService.logEntry(
          status: "success",
          countryCode: isoCode,
        );

        log(
          "${DateTime.now()} - Background task completed for country: $isoCode",
          name: 'Workmanager',
          time: DateTime.now(),
        );
      } else {
        // Still log an entry even if we don't have a country
        await locationService.logEntry(status: "error");

        log(
          "${DateTime.now()} - Background task failed: No country detected",
          name: 'Workmanager',
          level: 900,
          time: DateTime.now(),
        );
      }

      // Close the database to prevent memory leaks
      await backgroundDatabase.close();
    } catch (e, stack) {
      log(
        "Background task crashed",
        name: 'Workmanager',
        error: e,
        stackTrace: stack,
        level: 1000,
        time: DateTime.now(),
      );
      return Future.value(false);
    }

    return Future.value(true);
  });
}

void initializeWorkmanager({required bool isInDebugMode}) {
  log(
    "Initializing Workmanager (debugMode: $isInDebugMode)",
    name: 'Workmanager',
    level: 0,
    time: DateTime.now(),
  );

  Workmanager().initialize(callbackDispatcher, isInDebugMode: isInDebugMode);

  Workmanager().registerPeriodicTask(
    "1",
    fetchLocationInBackgroundTask,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}
