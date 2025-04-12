import 'dart:developer';
import 'package:trackie/data/repositories/log_country_relations_repository.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';

class CountryDataService {
  final LogCountryRelationsRepository logCountryRelationsRepository;
  final CountryVisitsRepository countryVisitsRepository;

  CountryDataService({
    required this.logCountryRelationsRepository,
    required this.countryVisitsRepository,
  });

  /// Delete a country and all its related data
  Future<void> deleteCountryData(String countryCode) async {
    try {
      log(
        '🗑️ Starting to delete country data for: $countryCode',
        name: 'CountryDataService',
        level: 0,
        time: DateTime.now(),
      );

      // Step 1: Delete all log-country relations for this country
      await logCountryRelationsRepository
          .deleteRelationsByCountryCode(countryCode);

      log(
        '🔗 Deleted log-country relations for: $countryCode',
        name: 'CountryDataService',
        level: 0,
        time: DateTime.now(),
      );

      // Step 2: Delete the country visit record
      await countryVisitsRepository.deleteCountryVisit(countryCode);

      log(
        '✅ Successfully deleted country data for: $countryCode',
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
