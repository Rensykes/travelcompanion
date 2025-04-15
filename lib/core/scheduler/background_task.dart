import 'dart:developer';
import 'dart:ui';
import 'package:trackie/application/services/sim_info_service.dart';
import 'package:trackie/core/utils/db_util.dart';
import 'package:workmanager/workmanager.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/application/services/location_service.dart';
import 'package:trackie/core/services/task_status_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const fetchLocationInBackgroundTask = "fetchLocationInBackgroundTask";

// Singleton instance of the database for background tasks
late AppDatabase backgroundDatabase;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Create tracking service
    final taskStatusService = TaskStatusService();
    bool taskSuccess = false;

    try {
      DartPluginRegistrant.ensureInitialized();

      // Initialize database for background task
      backgroundDatabase = AppDatabase();

      // Create repository instances
      final countryVisitsRepository =
          CountryVisitsRepository(backgroundDatabase);
      final locationLogsRepository = LocationLogsRepository(backgroundDatabase);

      // Create service using repositories
      final locationService = LocationService(
        locationLogsRepository: locationLogsRepository,
        countryVisitsRepository: countryVisitsRepository,
      );

      String? isoCode = await SimInfoService.getIsoCode();

      if (isoCode != null) {
        // Use the service to log the entry, which will handle all the complex logic
        await locationService.addEntry(
            logSource: DBUtils.scheduledEntry,
            countryCode: isoCode,
            logDateTime: DateTime.now());

        log(
          "${DateTime.now()} - Background task completed for country: $isoCode",
          name: 'Workmanager',
          time: DateTime.now(),
        );

        // Mark task as successful
        taskSuccess = true;
      } else {
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

      // The task failed due to an exception
      taskSuccess = false;
    }

    // Record the task execution status
    try {
      await taskStatusService.recordTaskExecution(success: taskSuccess);
    } catch (e) {
      log(
        "Failed to record task status: $e",
        name: 'Workmanager',
        error: e,
        level: 900,
        time: DateTime.now(),
      );
    }

    return Future.value(taskSuccess);
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
    existingWorkPolicy: ExistingWorkPolicy.replace,
    backoffPolicy: BackoffPolicy.linear,
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: false,
    ),
    initialDelay: const Duration(seconds: 10),
  );
}
