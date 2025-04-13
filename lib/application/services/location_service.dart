import 'dart:developer';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/models/one_time_visit.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';

/// Service responsible for managing location data and country visits throughout the application.
///
/// This service coordinates operations between the location logs and country visits repositories,
/// providing high-level business logic for tracking travel history and location data.
/// It handles operations such as:
/// - Adding new location entries
/// - Deleting country visits and logs
/// - Calculating days spent in countries
/// - Generating chronological visit histories
///
/// LocationService ensures data consistency across repositories and provides
/// the core travel tracking functionality of the application.
class LocationService {
  /// Repository for managing location log entries
  final LocationLogsRepository locationLogsRepository;

  /// Repository for managing country visit records
  final CountryVisitsRepository countryVisitsRepository;

  /// Creates a new LocationService with the required repositories.
  ///
  /// Parameters:
  /// - [locationLogsRepository]: Repository for location log operations
  /// - [countryVisitsRepository]: Repository for country visit operations
  LocationService({
    required this.locationLogsRepository,
    required this.countryVisitsRepository,
  });

  /// Adds a new location entry for a country.
  ///
  /// This method:
  /// 1. Creates a location log for the given country
  /// 2. Creates a new country visit record if this is the first visit
  /// 3. Updates an existing country visit with recalculated days if already visited
  ///
  /// Parameters:
  /// - [countryCode]: ISO code of the country (e.g., "US", "FR")
  /// - [logSource]: Source of the location data (e.g., "manual", "automatic")
  /// - [logDateTime]: Optional specific date/time for the entry (defaults to now)
  Future<void> addEntry({
    required String countryCode,
    required String logSource,
    DateTime? logDateTime,
  }) async {
    log(
      "🌍 Adding new location entry for $countryCode",
      name: 'LocationService',
      level: 0,
      time: DateTime.now(),
    );

    final dateTime = logDateTime ?? DateTime.now();

    // Create the location log
    await locationLogsRepository.createLocationLog(
      logDateTime: dateTime,
      status: logSource,
      countryCode: countryCode,
    );

    // Check if country visit exists
    final countryVisit =
        await countryVisitsRepository.getVisitByCountryCode(countryCode);

    if (countryVisit == null) {
      // Create new country visit if it doesn't exist
      await countryVisitsRepository.createCountryVisit(
        countryCode: countryCode,
        entryDate: dateTime,
        daysSpent: 1,
      );
    } else {
      // Update days spent if country visit already exists
      final daysSpent = await calculateDaysSpent(countryCode);
      await countryVisitsRepository.updateCountryVisit(
        countryCode: countryCode,
        daysSpent: daysSpent,
      );
    }

    log(
      "✅ Successfully added location entry for $countryCode",
      name: 'LocationService',
      level: 1,
      time: DateTime.now(),
    );
  }

  /// Deletes a country visit and all its associated location logs.
  ///
  /// This is a complete removal operation that:
  /// 1. Deletes the country visit record
  /// 2. Deletes all location logs associated with the country
  ///
  /// Parameters:
  /// - [countryCode]: ISO code of the country to delete
  ///
  /// Throws an exception if the deletion fails.
  Future<void> deleteCountryVisit(String countryCode) async {
    log(
      "🗑️ Deleting country visit and all logs for $countryCode",
      name: 'LocationService',
      level: 0,
      time: DateTime.now(),
    );

    try {
      // Delete the country visit
      await countryVisitsRepository.deleteCountryVisit(countryCode);

      // Delete all associated logs
      await locationLogsRepository.deleteLogsByCountryCode(countryCode);

      log(
        "✅ Successfully deleted country visit and logs for $countryCode",
        name: 'LocationService',
        level: 1,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while deleting country visit: $e",
        name: 'LocationService',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Deletes a specific location log by ID and updates or deletes the related country visit.
  ///
  /// This method:
  /// 1. Deletes the specified log entry
  /// 2. Checks if any logs remain for the country
  /// 3. If no logs remain, deletes the country visit
  /// 4. If logs remain, recalculates days spent and updates the country visit
  ///
  /// Parameters:
  /// - [id]: Database ID of the log to delete
  /// - [countryCode]: ISO code of the country the log belongs to
  ///
  /// Throws an exception if the operation fails.
  Future<void> deleteLocationLogByIdAndCountryCode(
      int id, String countryCode) async {
    log(
      "🗑️ Deleting location log ID: $id for country: $countryCode",
      name: 'LocationService',
      level: 0,
      time: DateTime.now(),
    );

    try {
      // Delete the log
      await locationLogsRepository.deleteLog(id);

      // Check remaining logs for this country
      final logs =
          await locationLogsRepository.getLogsByCountryCode(countryCode);

      if (logs.isEmpty) {
        // Delete country visit if no logs remain
        await countryVisitsRepository.deleteCountryVisit(countryCode);

        log(
          "ℹ️ No logs remain for $countryCode - country visit deleted",
          name: 'LocationService',
          level: 0,
          time: DateTime.now(),
        );
      } else {
        // Update days spent if logs still exist
        final daysSpent = await calculateDaysSpent(countryCode);
        await countryVisitsRepository.updateCountryVisit(
          countryCode: countryCode,
          daysSpent: daysSpent,
        );

        log(
          "ℹ️ Updated days spent for $countryCode to $daysSpent days",
          name: 'LocationService',
          level: 0,
          time: DateTime.now(),
        );
      }

      log(
        "✅ Successfully processed location log deletion",
        name: 'LocationService',
        level: 1,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while deleting location log: $e",
        name: 'LocationService',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Calculates the number of unique days spent in a country.
  ///
  /// This method:
  /// 1. Retrieves all location logs for a country
  /// 2. Identifies unique calendar days (ignoring time)
  /// 3. Counts the number of unique days as the days spent
  ///
  /// Parameters:
  /// - [countryCode]: ISO code of the country to calculate days for
  ///
  /// Returns:
  /// The number of unique days with location logs for the country
  Future<int> calculateDaysSpent(String countryCode) async {
    log(
      "🧮 Calculating days spent in $countryCode",
      name: 'LocationService',
      level: 0,
      time: DateTime.now(),
    );

    final logs = await locationLogsRepository.getLogsByCountryCode(countryCode);

    if (logs.isEmpty) {
      return 0;
    }

    // Get all unique dates where location was logged
    final uniqueDates = <DateTime>{};

    for (final log in logs) {
      // Add just the date part, ignoring time
      final dateOnly = DateTime(
        log.logDateTime.year,
        log.logDateTime.month,
        log.logDateTime.day,
      );
      uniqueDates.add(dateOnly);
    }

    final daysSpent = uniqueDates.length;

    log(
      "📊 Calculated $daysSpent days spent in $countryCode",
      name: 'LocationService',
      level: 0,
      time: DateTime.now(),
    );

    return daysSpent;
  }

  /// Generates a chronological timeline of country visits.
  ///
  /// This method processes all location logs to create a timeline of one-time visits,
  /// with proper entry and exit dates for each country. It groups logs by country and
  /// identifies country changes as new visits.
  ///
  /// Returns:
  /// A list of [OneTimeVisit] objects representing the travel history timeline
  Future<List<OneTimeVisit>> getOneTimeVisits() async {
    log(
      "🧭 Generating historical country visits timeline",
      name: 'LocationService',
      level: 0,
      time: DateTime.now(),
    );

    try {
      // Get all logs ordered by date (oldest first)
      final allLogs = await locationLogsRepository.getAllLogs();

      // Sort logs from oldest to newest
      allLogs.sort((a, b) => a.logDateTime.compareTo(b.logDateTime));

      // Filter out logs with no country code
      final validLogs =
          allLogs.where((log) => log.countryCode != null).toList();

      if (validLogs.isEmpty) {
        log(
          "ℹ️ No location logs with country codes found",
          name: 'LocationService',
          level: 0,
          time: DateTime.now(),
        );
        return [];
      }

      final visits = <OneTimeVisit>[];
      String? currentCountry;
      DateTime? entryDate;
      List<LocationLog> currentLogs = [];

      for (int i = 0; i < validLogs.length; i++) {
        final log = validLogs[i];
        final logCountry = log.countryCode!;

        // First log or new country detected
        if (currentCountry == null || currentCountry != logCountry) {
          // If we were tracking a country before, add it to visits with an exit date
          if (currentCountry != null) {
            // Get the previous log's date as the exit date
            final exitDate = log.logDateTime;

            visits.add(OneTimeVisit(
              countryCode: currentCountry,
              entryDate: entryDate!,
              exitDate: exitDate,
              locationLogs: List.from(currentLogs),
            ));

            // Reset for new country
            currentLogs = [];
          }

          // Start tracking new country
          currentCountry = logCountry;
          entryDate = log.logDateTime;
        }

        // Add log to current visit
        currentLogs.add(log);

        // If this is the last log, add the final visit without an exit date
        if (i == validLogs.length - 1) {
          visits.add(OneTimeVisit(
            countryCode: currentCountry,
            entryDate: entryDate!,
            exitDate: null, // Still in this country
            locationLogs: List.from(currentLogs),
          ));
        }
      }

      log(
        "📊 Generated ${visits.length} historical country visits",
        name: 'LocationService',
        level: 0,
        time: DateTime.now(),
      );

      return visits;
    } catch (e) {
      log(
        "❌ Error generating historical visits: $e",
        name: 'LocationService',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }
}
