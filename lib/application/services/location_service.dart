import 'dart:developer';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/models/one_time_visit.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';

/// Service class to manage location tracking functionality
class LocationService {
  final LocationLogsRepository locationLogsRepository;
  final CountryVisitsRepository countryVisitsRepository;

  LocationService({
    required this.locationLogsRepository,
    required this.countryVisitsRepository,
  });

  /// Add a new location entry for a country
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

  /// Delete a country visit and all its associated logs
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

  /// Delete a specific location log and update or delete the country visit if needed
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

  /// Calculate days spent in a country based on location logs
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

  /// Generate a list of OneTimeVisit objects representing the historical country visits
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
