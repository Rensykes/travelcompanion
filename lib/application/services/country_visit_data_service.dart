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
      // Get all logs for this country
      final logs = await locationLogsRepository.getRelationsForCountryVisit(
        countryCode,
      );

      // Delete each log
      for (var log in logs) {
        await locationLogsRepository.deleteLog(log.id);
      }

      // Delete the country visit
      await countryVisitsRepository.deleteCountryVisit(countryCode);

      log("🗑️ All data deleted for country: $countryCode");
    } catch (e) {
      log("❌ Error deleting country data: $e");
      rethrow; // Rethrow to handle in the UI
    }
  }
}
