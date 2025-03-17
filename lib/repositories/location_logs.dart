import 'dart:developer';
import 'package:drift/drift.dart';
import '../database/database.dart';

class LocationLogsRepository {
  final AppDatabase database;

  LocationLogsRepository(this.database);

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

  /// Delete a log entry by its ID
  Future<void> deleteLog(int id) async {
    try {
      await (database.delete(database.locationLogs)
        ..where((log) => log.id.equals(id)))
        .go();
      log("🗑️ Log Deleted: ID - $id");
    } catch (e) {
      log("❌ Error while deleting log: $e");
    }
  }
}

