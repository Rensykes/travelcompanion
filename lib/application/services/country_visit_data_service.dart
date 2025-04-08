import 'dart:developer';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';

class CountryDataService {
  final LocationLogsRepository locationLogsRepository;
  final CountryVisitsRepository countryVisitsRepository;

  CountryDataService({
    required this.locationLogsRepository,
    required this.countryVisitsRepository,
  });

  /// Delete a country and all its related logs
  Future<void> deleteCountryData(String countryCode) async {
    try {
      final logs = await locationLogsRepository.getRelationsForCountryVisit(
        countryCode,
      );

      for (var logEntry in logs) {
        await locationLogsRepository.deleteLog(logEntry.id);
      }

      await countryVisitsRepository.deleteCountryVisit(countryCode);

      log(
        '🗑️ Deleted country data: $countryCode with ${logs.length} related log(s)',
        name: 'CountryDataService',
        level: 0,
        time: DateTime.now(),
      );
    } catch (e, stack) {
      log(
        '❌ Error deleting country data: $countryCode',
        name: 'CountryDataService',
        error: e,
        stackTrace: stack,
        level: 1000,
        time: DateTime.now(),
      );
      rethrow; // Let the UI handle it if needed
    }
  }
}
