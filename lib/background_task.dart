// background_task.dart

import 'dart:developer';
import 'dart:ui';
import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/location_service.dart';
import 'services/country_service.dart';
import 'services/log_service.dart';
import 'db/country_adapter.dart';
import 'db/location_log.dart';

const fetchLocationInBackgroundTask = "fetchLocationInBackgroundTask";

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

      String? placemark = await LocationService.getCurrentCountry();

      if (placemark != null) {
        await CountryService.saveCountryVisit(placemark);

        // ✅ Use LogService to log success
        await LogService.logEntry(status: "success", countryCode: placemark);
        DateTime dateTime = DateTime.now();
        log("✅ Background Task Success: Country - $placemark - $dateTime");
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

void initializeWorkmanager() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "1",
    fetchLocationInBackgroundTask,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep, // Avoid multiple instances
  );
}
