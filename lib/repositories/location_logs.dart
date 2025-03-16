import 'dart:developer';
import 'package:drift/drift.dart';

import '../database/database.dart';

class LocationLogsRepository {
  final AppDatabase database;

  LocationLogsRepository(this.database);

  /// Logs a new entry in the location_logs table
  Future<void> logEntry({required String status, String? countryCode}) async {
    try {
      await database.into(database.locationLogs).insert(
        LocationLogsCompanion.insert(
          logDateTime: DateTime.now(),
          status: status,
          countryCode: Value(countryCode),
        ),
      );
      log("📝 Log Added: Status - $status, Country - ${countryCode ?? 'N/A'}");
    } catch (e) {
      log("❌ Error while logging: $e");
    }
  }
  
  /// Get all logs
  Future<List<LocationLog>> getAllLogs() {
    return (database.select(database.locationLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.logDateTime, mode: OrderingMode.desc)]))
      .get();
  }
  
  /// Watch all logs as a stream (for reactive UI)
  Stream<List<LocationLog>> watchAllLogs() {
    return (database.select(database.locationLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.logDateTime, mode: OrderingMode.desc)]))
      .watch();
  }
}