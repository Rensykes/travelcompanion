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
    DateTime.now().toIso8601String();
    log(
      "🔍 Fetching location logs for country: $countryCode",
      name: 'LocationLogsRepository',
      level: 0, // INFO
      time: DateTime.now(),
    );
    final relations = await (database.select(database.logCountryRelations)
          ..where((r) => r.countryCode.equals(countryCode)))
        .join([
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
    log(
      "📊 Retrieved ${logs.length} location logs for $countryCode",
      name: 'LocationLogsRepository',
      level: 0, // INFO
      time: DateTime.now(),
    );
    return logs;
  }

  /// Logs a new entry in the location_logs table
  Future<void> logEntry({
    required String status,
    String? countryCode,
    String? notes,
    DateTime? logDateTime,
  }) async {
    DateTime.now().toIso8601String();
    log(
      "📝 Starting to log new location entry - Status: $status, Country: $countryCode, Notes: ${notes ?? 'None'}, Date: ${logDateTime?.toIso8601String() ?? 'Current time'}",
      name: 'LocationLogsRepository',
      level: 0, // INFO
      time: DateTime.now(),
    );
    try {
      // Update the LocationLogsCompanion to include notes
      // Since the LocationLogs table doesn't have a notes column, we can't store it directly
      // We could consider adding it in a future schema update

      final logLocation =
          await database.into(database.locationLogs).insertReturning(
                LocationLogsCompanion.insert(
                  logDateTime: logDateTime ?? DateTime.now(),
                  status: status,
                  countryCode: Value(countryCode),
                ),
              );
      final logId = logLocation.id; // Extract ID from the returned log

      if (countryCode != null) {
        log(
          "🔗 Creating relation between log $logId and country $countryCode",
          name: 'LocationLogsRepository',
          level: 0, // INFO
          time: DateTime.now(),
        );
        await database.into(database.logCountryRelations).insert(
              LogCountryRelationsCompanion.insert(
                logId: logId,
                countryCode: countryCode,
              ),
            );
        log(
          "✅ Successfully logged location entry - ID: $logId, Status: $status, Country: $countryCode",
          name: 'LocationLogsRepository',
          level: 1, // SUCCESS
          time: DateTime.now(),
        );
      } else {
        log(
          "✅ Successfully logged location entry - ID: $logId, Status: $status",
          name: 'LocationLogsRepository',
          level: 1, // SUCCESS
          time: DateTime.now(),
        );
      }
    } catch (e) {
      log(
        "❌ Error while logging location entry: $e",
        name: 'LocationLogsRepository',
        level: 3, // ERROR
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Get all logs
  Future<List<LocationLog>> getAllLogs() async {
    DateTime.now().toIso8601String();
    log(
      "📋 Fetching all location logs",
      name: 'LocationLogsRepository',
      level: 0, // INFO
      time: DateTime.now(),
    );
    final logs = await (database.select(database.locationLogs)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.logDateTime, mode: OrderingMode.desc),
          ]))
        .get();
    log(
      "📊 Retrieved ${logs.length} location logs",
      name: 'LocationLogsRepository',
      level: 0, // INFO
      time: DateTime.now(),
    );
    return logs;
  }

  /// Delete a log entry by its ID and remove related entries
  Future<void> deleteLog(int id) async {
    DateTime.now().toIso8601String();
    log(
      "🗑️ Starting to delete log entry with ID: $id",
      name: 'LocationLogsRepository',
      level: 0, // INFO
      time: DateTime.now(),
    );
    try {
      // First get the log to be deleted to know its country code
      final logToDelete = await (database.select(database.locationLogs)
            ..where((log) => log.id.equals(id)))
          .getSingleOrNull();

      if (logToDelete == null) {
        log(
          "⚠️ Log not found for deletion: ID - $id",
          name: 'LocationLogsRepository',
          level: 2, // WARN
          time: DateTime.now(),
        );
        return;
      }

      String? affectedCountryCode = logToDelete.countryCode;
      log(
        "📝 Found log to delete - ID: $id, Country: $affectedCountryCode",
        name: 'LocationLogsRepository',
        level: 0, // INFO
        time: DateTime.now(),
      );

      // Delete related entries in logCountryRelations
      await (database.delete(database.logCountryRelations)
            ..where((relation) => relation.logId.equals(id)))
          .go();
      log(
        "🔗 Deleted related entries for log ID: $id",
        name: 'LocationLogsRepository',
        level: 1, // SUCCESS
        time: DateTime.now(),
      );

      // Delete the actual log entry
      await (database.delete(database.locationLogs)
            ..where((log) => log.id.equals(id)))
          .go();
      log(
        "✅ Successfully deleted log entry with ID: $id",
        name: 'LocationLogsRepository',
        level: 1, // SUCCESS
        time: DateTime.now(),
      );

      // Recalculate daysSpent for the affected country if there was one
      if (affectedCountryCode != null) {
        log(
          "🔄 Recalculating days spent for country: $affectedCountryCode",
          name: 'LocationLogsRepository',
          level: 0, // INFO
          time: DateTime.now(),
        );
        await recalculateDaysSpent(affectedCountryCode);
      }
    } catch (e) {
      log(
        "❌ Error while deleting log: $e",
        name: 'LocationLogsRepository',
        level: 3, // ERROR
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Recalculate the daysSpent value for a country based on LocationLogs
  Future<void> recalculateDaysSpent(String countryCode) async {
    log(
      "🔄 Starting to recalculate days spent for country: $countryCode",
      name: 'LocationLogsRepository',
      level: 0, // INFO
      time: DateTime.now(),
    );
    try {
      // Get all logs for this country
      final logs = await getRelationsForCountryVisit(countryCode);

      if (logs.isEmpty) {
        log(
          "⚠️ No logs found for $countryCode, removing country visit record",
          name: 'LocationLogsRepository',
          level: 2, // WARN
          time: DateTime.now(),
        );
        // If no logs left, delete the country visit record
        await (database.delete(database.countryVisits)
              ..where((visit) => visit.countryCode.equals(countryCode)))
            .go();
        log(
          "🗑️ Removed country visit record for $countryCode",
          name: 'LocationLogsRepository',
          level: 1, // SUCCESS
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
        name: 'LocationLogsRepository',
        level: 0, // INFO
        time: DateTime.now(),
      );

      // Check if country visit exists
      final existingVisit = await (database.select(database.countryVisits)
            ..where((visit) => visit.countryCode.equals(countryCode)))
          .getSingleOrNull();

      if (existingVisit == null) {
        // Create new country visit
        log(
          "✨ Creating new country visit for $countryCode",
          name: 'LocationLogsRepository',
          level: 0, // INFO
          time: DateTime.now(),
        );
        await database.into(database.countryVisits).insert(
              CountryVisitsCompanion.insert(
                countryCode: countryCode,
                entryDate: entryDate,
                daysSpent: uniqueDates.length,
              ),
            );
      } else {
        // Update existing country visit
        await (database.update(database.countryVisits)
              ..where((visit) => visit.countryCode.equals(countryCode)))
            .write(
          CountryVisitsCompanion(
            entryDate: Value(entryDate),
            daysSpent: Value(uniqueDates.length),
          ),
        );
      }

      log(
        "✅ Successfully updated days spent for $countryCode: ${uniqueDates.length} days",
        name: 'LocationLogsRepository',
        level: 1, // SUCCESS
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while recalculating days spent: $e",
        name: 'LocationLogsRepository',
        level: 3, // ERROR
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }
}
