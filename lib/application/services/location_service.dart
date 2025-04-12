import 'dart:developer';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/log_country_relations_repository.dart';

class LocationService {
  final LocationLogsRepository locationLogsRepository;
  final CountryVisitsRepository countryVisitsRepository;
  final LogCountryRelationsRepository logCountryRelationsRepository;

  LocationService({
    required this.locationLogsRepository,
    required this.countryVisitsRepository,
    required this.logCountryRelationsRepository,
  });

  /// Log a new location entry with all related data
  Future<void> logEntry({
    required String status,
    String? countryCode,
    DateTime? logDateTime,
  }) async {
    log(
      "📝 Starting to log new location entry - Status: $status, Country: $countryCode, Date: ${logDateTime?.toIso8601String() ?? 'Current time'}",
      name: 'LocationService',
      level: 0,
      time: DateTime.now(),
    );

    try {
      // 1. Create the location log
      final logLocation = await locationLogsRepository.createLocationLog(
        logDateTime: logDateTime ?? DateTime.now(),
        status: status,
        countryCode: countryCode,
      );

      // 2. If a country code is provided, create a relation and update country visit
      if (countryCode != null) {
        // Create relation between log and country
        await logCountryRelationsRepository.createRelation(
          logId: logLocation.id,
          countryCode: countryCode,
        );

        // Update or create country visit
        await updateCountryVisit(countryCode);

        log(
          "✅ Successfully logged location entry with country relation - ID: ${logLocation.id}, Country: $countryCode",
          name: 'LocationService',
          level: 1,
          time: DateTime.now(),
        );
      } else {
        log(
          "✅ Successfully logged location entry - ID: ${logLocation.id}",
          name: 'LocationService',
          level: 1,
          time: DateTime.now(),
        );
      }
    } catch (e) {
      log(
        "❌ Error while logging location entry: $e",
        name: 'LocationService',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Delete a log and update related data
  Future<void> deleteLogAndUpdateRelations(int logId) async {
    log(
      "🗑️ Starting to delete log and update relations - ID: $logId",
      name: 'LocationService',
      level: 0,
      time: DateTime.now(),
    );

    try {
      // 1. Get the log to check if it has a country code
      final logToDelete = await locationLogsRepository.getLogById(logId);

      if (logToDelete == null) {
        log(
          "⚠️ Log not found for deletion: ID - $logId",
          name: 'LocationService',
          level: 2,
          time: DateTime.now(),
        );
        return;
      }

      String? affectedCountryCode = logToDelete.countryCode;

      // 2. Delete relations for this log
      await logCountryRelationsRepository.deleteRelationsByLogId(logId);

      // 3. Delete the log
      await locationLogsRepository.deleteLog(logId);

      // 4. If the log had a country code, recalculate days spent
      if (affectedCountryCode != null) {
        await recalculateDaysSpent(affectedCountryCode);
      }

      log(
        "✅ Successfully deleted log and updated relations - ID: $logId",
        name: 'LocationService',
        level: 1,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while deleting log and updating relations: $e",
        name: 'LocationService',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Update a country visit with a specific date
  Future<void> saveCountryVisitWithDate(
      String countryCode, DateTime date) async {
    log(
      "🌍 Saving country visit for: $countryCode with specific date: $date",
      name: 'LocationService',
      level: 0,
      time: DateTime.now(),
    );

    try {
      final formattedDate = DateTime(date.year, date.month, date.day);

      // Log a new entry for this country with the specified date
      final logLocation = await locationLogsRepository.createLocationLog(
        logDateTime: formattedDate,
        status: "MANUAL",
        countryCode: countryCode,
      );

      // Create relation
      await logCountryRelationsRepository.createRelation(
        logId: logLocation.id,
        countryCode: countryCode,
      );

      // Update country visit
      await updateCountryVisit(countryCode);

      log(
        "✅ Successfully saved country visit with date - Country: $countryCode, Date: $formattedDate",
        name: 'LocationService',
        level: 1,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while saving country visit with date: $e",
        name: 'LocationService',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Recalculate days spent for a country
  Future<void> recalculateDaysSpent(String countryCode) async {
    log(
      "🔄 Starting to recalculate days spent for country: $countryCode",
      name: 'LocationService',
      level: 0,
      time: DateTime.now(),
    );

    try {
      // Get all logs for this country using join
      final logs = await logCountryRelationsRepository
          .getLogsByCountryCodeJoin(countryCode);

      if (logs.isEmpty) {
        log(
          "⚠️ No logs found for $countryCode, removing country visit record",
          name: 'LocationService',
          level: 2,
          time: DateTime.now(),
        );

        // If no logs left, delete the country visit record
        await countryVisitsRepository.deleteCountryVisit(countryCode);

        log(
          "🗑️ Removed country visit record for $countryCode",
          name: 'LocationService',
          level: 1,
          time: DateTime.now(),
        );
        return;
      }

      // Get unique dates from the logs
      final Set<DateTime> uniqueDates = {};
      for (var log in logs) {
        final logDate = DateTime(
          log.logDateTime.year,
          log.logDateTime.month,
          log.logDateTime.day,
        );
        uniqueDates.add(logDate);
      }

      // Get the earliest date (entry date)
      final entryDate = uniqueDates.reduce((a, b) => a.isBefore(b) ? a : b);

      log(
        "📅 Calculated entry date: $entryDate, Total unique days: ${uniqueDates.length}",
        name: 'LocationService',
        level: 0,
        time: DateTime.now(),
      );

      // Check if country visit exists
      final existingVisit =
          await countryVisitsRepository.getVisitByCountryCode(countryCode);

      if (existingVisit == null) {
        // Create new country visit
        await countryVisitsRepository.createCountryVisit(
          countryCode: countryCode,
          entryDate: entryDate,
          daysSpent: uniqueDates.length,
        );
      } else {
        // Update existing country visit
        await countryVisitsRepository.updateCountryVisit(
          countryCode: countryCode,
          entryDate: entryDate,
          daysSpent: uniqueDates.length,
        );
      }

      log(
        "✅ Successfully updated days spent for $countryCode: ${uniqueDates.length} days",
        name: 'LocationService',
        level: 1,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while recalculating days spent: $e",
        name: 'LocationService',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Update a country visit record
  Future<void> updateCountryVisit(String countryCode) async {
    log(
      "🌍 Updating country visit for: $countryCode",
      name: 'LocationService',
      level: 0,
      time: DateTime.now(),
    );

    try {
      final today = DateTime.now();
      final formattedToday = DateTime(today.year, today.month, today.day);

      // Check if there's an existing entry for this country
      final existingVisit =
          await countryVisitsRepository.getVisitByCountryCode(countryCode);

      if (existingVisit != null) {
        log(
          "📝 Found existing visit for $countryCode with ${existingVisit.daysSpent} days spent",
          name: 'LocationService',
          level: 0,
          time: DateTime.now(),
        );

        // Recalculate days spent for accurate counting
        await recalculateDaysSpent(countryCode);
      } else {
        log(
          "✨ Creating new country visit entry for $countryCode",
          name: 'LocationService',
          level: 0,
          time: DateTime.now(),
        );

        // It's a new country, create a new entry
        await countryVisitsRepository.createCountryVisit(
          countryCode: countryCode,
          entryDate: formattedToday,
          daysSpent: 1,
        );

        log(
          "✅ Successfully created new country visit for $countryCode",
          name: 'LocationService',
          level: 1,
          time: DateTime.now(),
        );
      }
    } catch (e) {
      log(
        "❌ Error while updating country visit: $e",
        name: 'LocationService',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }
}
