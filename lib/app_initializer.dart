import 'package:hive_flutter/hive_flutter.dart';
import 'utils/hive_constants.dart';
import 'db/country_adapter.dart';
import 'db/location_log.dart';

Future<void> initializeApp() async {
  try {
    if (!Hive.isBoxOpen(countryVisitsBoxName)) {
      var countryVisitsBox = await Hive.openBox<CountryVisit>(
        countryVisitsBoxName,
      );
      await countryVisitsBox.close(); // Ensure the box is closed after initialization
    }
    if (!Hive.isBoxOpen(locationLogsBoxName)) {
      var locationLogBox = await Hive.openBox<LocationLog>(locationLogsBoxName);
      await locationLogBox.close(); // Ensure the box is closed after initialization
    }
  } catch (e, stackTrace) {
    throw AppInitializationException(
      'Failed to initialize app: $e',
      stackTrace,
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