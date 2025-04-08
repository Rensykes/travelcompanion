import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:trackie/data/datasource/database.dart';

class LocationLogsRepository {
  final AppDatabase database;

  LocationLogsRepository(this.database);

  /// Fetch all log relations for a given country code
  Future<List<LocationLog>> getRelationsForCountryVisit(
    String countryCode,
  ) async {
    log("🔍 Fetching location logs for country: $countryCode");
    final relations =
        await (database.select(database.logCountryRelations)
          ..where((r) => r.countryCode.equals(countryCode))).join([
          leftOuterJoin(
            database.locationLogs,
            database.locationLogs.id.equalsExp(
              database.logCountryRelations.logId,
            ),
          ),
        ]).get();

    // Extract the LocationLog entries from the joined result
    final logs =
        relations.map((row) => row.readTable(database.locationLogs)).toList();
    log("📊 Retrieved ${logs.length} location logs for $countryCode");
    return logs;
  }

  /// Logs a new entry in the location_logs table
  Future<void> logEntry({required String status, String? countryCode}) async {
    log(
      "📝 Starting to log new location entry - Status: $status, Country: $countryCode",
    );
    try {
      final logLocation = await database
          .into(database.locationLogs)
          .insertReturning(
            LocationLogsCompanion.insert(
              logDateTime: DateTime.now(),
              status: status,
              countryCode: Value(countryCode),
            ),
          );
      final logId = logLocation.id; // Extract ID from the returned log

      if (countryCode != null) {
        log("🔗 Creating relation between log $logId and country $countryCode");
        await database
            .into(database.logCountryRelations)
            .insert(
              LogCountryRelationsCompanion.insert(
                logId: logId,
                countryCode: countryCode,
              ),
            );
        log(
          "✅ Successfully logged location entry - ID: $logId, Status: $status, Country: $countryCode",
        );
      } else {
        log(
          "✅ Successfully logged location entry - ID: $logId, Status: $status",
        );
      }
    } catch (e) {
      log("❌ Error while logging location entry: $e");
      rethrow;
    }
  }

  /// Get all logs
  Future<List<LocationLog>> getAllLogs() async {
    log("📋 Fetching all location logs");
    final logs =
        await (database.select(database.locationLogs)..orderBy([
          (t) =>
              OrderingTerm(expression: t.logDateTime, mode: OrderingMode.desc),
        ])).get();
    log("📊 Retrieved ${logs.length} location logs");
    return logs;
  }

  /// Delete a log entry by its ID and remove related entries
  Future<void> deleteLog(int id) async {
    log("🗑️ Starting to delete log entry with ID: $id");
    try {
      // First get the log to be deleted to know its country code
      final logToDelete =
          await (database.select(database.locationLogs)
            ..where((log) => log.id.equals(id))).getSingleOrNull();

      if (logToDelete == null) {
        log("⚠️ Log not found for deletion: ID - $id");
        return;
      }

      String? affectedCountryCode = logToDelete.countryCode;
      log("📝 Found log to delete - ID: $id, Country: $affectedCountryCode");

      // Delete related entries in logCountryRelations
      await (database.delete(database.logCountryRelations)
        ..where((relation) => relation.logId.equals(id))).go();
      log("🔗 Deleted related entries for log ID: $id");

      // Delete the actual log entry
      await (database.delete(database.locationLogs)
        ..where((log) => log.id.equals(id))).go();
      log("✅ Successfully deleted log entry with ID: $id");

      // Recalculate daysSpent for the affected country if there was one
      if (affectedCountryCode != null) {
        log("🔄 Recalculating days spent for country: $affectedCountryCode");
        await recalculateDaysSpent(affectedCountryCode);
      }
    } catch (e) {
      log("❌ Error while deleting log: $e");
      rethrow;
    }
  }

  /// Recalculate the daysSpent value for a country based on LocationLogs
  Future<void> recalculateDaysSpent(String countryCode) async {
    log("🔄 Starting to recalculate days spent for country: $countryCode");
    try {
      // Get all logs for this country
      final logs = await getRelationsForCountryVisit(countryCode);

      if (logs.isEmpty) {
        log("⚠️ No logs found for $countryCode, removing country visit record");
        // If no logs left, delete the country visit record
        await (database.delete(database.countryVisits)
          ..where((visit) => visit.countryCode.equals(countryCode))).go();
        log("🗑️ Removed country visit record for $countryCode");
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
      );

      // Update the country visit with the new values
      await (database.update(database.countryVisits)
        ..where((visit) => visit.countryCode.equals(countryCode))).write(
        CountryVisitsCompanion(
          entryDate: Value(entryDate),
          daysSpent: Value(uniqueDates.length),
        ),
      );

      log(
        "✅ Successfully updated days spent for $countryCode: ${uniqueDates.length} days",
      );
    } catch (e) {
      log("❌ Error while recalculating days spent: $e");
      rethrow;
    }
  }
}
