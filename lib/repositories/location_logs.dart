import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:trackie/database/database.dart';

class LocationLogsRepository {
  final AppDatabase database;

  LocationLogsRepository(this.database);


  /// Fetch all log relations for a given country code
  Future<List<LocationLog>> getRelationsForCountryVisit(String countryCode) async {
    final relations = await (database.select(database.logCountryRelations)
          ..where((r) => r.countryCode.equals(countryCode)))
        .join([
          leftOuterJoin(database.locationLogs, database.locationLogs.id.equalsExp(database.logCountryRelations.logId)),
        ])
        .get();

    // Extract the LocationLog entries from the joined result
    return relations.map((row) => row.readTable(database.locationLogs)).toList();
  }

  /// Logs a new entry in the location_logs table
  Future<void> logEntry({required String status, String? countryCode}) async {
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
        await database
            .into(database.logCountryRelations)
            .insert(
              LogCountryRelationsCompanion.insert(
                logId: logId,
                countryCode: countryCode,
              ),
            );
        log("📝 Log Added: Status - $status, Country - $countryCode");
      }
    } catch (e) {
      log("❌ Error while logging: $e");
    }
  }

  /// Get all logs
  Future<List<LocationLog>> getAllLogs() {
    return (database.select(database.locationLogs)..orderBy([
      (t) => OrderingTerm(expression: t.logDateTime, mode: OrderingMode.desc),
    ])).get();
  }

  /// Watch all logs as a stream (for reactive UI)
  Stream<List<LocationLog>> watchAllLogs() {
    return (database.select(database.locationLogs)..orderBy([
      (t) => OrderingTerm(expression: t.logDateTime, mode: OrderingMode.desc),
    ])).watch();
  }

  /// Delete a log entry by its ID and remove related entries
  Future<void> deleteLog(int id) async {
    try {
      // Delete related entries in logCountryRelations
      await (database.delete(database.logCountryRelations)
        ..where((relation) => relation.logId.equals(id))).go();

      // Delete the actual log entry
      await (database.delete(database.locationLogs)
        ..where((log) => log.id.equals(id))).go();

      log("🗑️ Log Deleted: ID - $id and its relations");
    } catch (e) {
      log("❌ Error while deleting log: $e");
    }
  }
}
