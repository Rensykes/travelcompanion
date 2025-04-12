import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:trackie/data/datasource/database.dart';

class LocationLogsRepository {
  final AppDatabase database;

  LocationLogsRepository(this.database);

  /// Create a new location log entry
  Future<LocationLog> createLocationLog({
    required DateTime logDateTime,
    required String status,
    String? countryCode,
  }) async {
    log(
      "📝 Creating new location log - Status: $status, Country: $countryCode, Date: ${logDateTime.toIso8601String()}",
      name: 'LocationLogsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      final logLocation =
          await database.into(database.locationLogs).insertReturning(
                LocationLogsCompanion.insert(
                  logDateTime: logDateTime,
                  status: status,
                  countryCode: Value(countryCode),
                ),
              );

      log(
        "✅ Successfully created location log - ID: ${logLocation.id}, Status: $status, Country: $countryCode",
        name: 'LocationLogsRepository',
        level: 1,
        time: DateTime.now(),
      );

      return logLocation;
    } catch (e) {
      log(
        "❌ Error while creating location log: $e",
        name: 'LocationLogsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Get a location log by ID
  Future<LocationLog?> getLogById(int id) async {
    log(
      "🔍 Fetching location log with ID: $id",
      name: 'LocationLogsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      final log = await (database.select(database.locationLogs)
            ..where((log) => log.id.equals(id)))
          .getSingleOrNull();

      return log;
    } catch (e) {
      log(
        "❌ Error while fetching location log: $e",
        name: 'LocationLogsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Get logs by country code
  Future<List<LocationLog>> getLogsByCountryCode(String countryCode) async {
    log(
      "🔍 Fetching location logs for country: $countryCode",
      name: 'LocationLogsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      final logs = await (database.select(database.locationLogs)
            ..where((log) => log.countryCode.equals(countryCode))
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.logDateTime, mode: OrderingMode.desc),
            ]))
          .get();

      log(
        "📊 Retrieved ${logs.length} location logs for $countryCode",
        name: 'LocationLogsRepository',
        level: 0,
        time: DateTime.now(),
      );

      return logs;
    } catch (e) {
      log(
        "❌ Error while fetching location logs: $e",
        name: 'LocationLogsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Get all logs
  Future<List<LocationLog>> getAllLogs() async {
    log(
      "📋 Fetching all location logs",
      name: 'LocationLogsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      final logs = await (database.select(database.locationLogs)
            ..orderBy([
              (t) => OrderingTerm(
                  expression: t.logDateTime, mode: OrderingMode.desc),
            ]))
          .get();

      log(
        "📊 Retrieved ${logs.length} location logs",
        name: 'LocationLogsRepository',
        level: 0,
        time: DateTime.now(),
      );

      return logs;
    } catch (e) {
      log(
        "❌ Error while fetching all location logs: $e",
        name: 'LocationLogsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Delete a log entry by its ID
  Future<void> deleteLog(int id) async {
    log(
      "🗑️ Deleting log entry with ID: $id",
      name: 'LocationLogsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      // Delete the log entry
      await (database.delete(database.locationLogs)
            ..where((log) => log.id.equals(id)))
          .go();

      log(
        "✅ Successfully deleted log entry with ID: $id",
        name: 'LocationLogsRepository',
        level: 1,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while deleting log: $e",
        name: 'LocationLogsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Update a location log
  Future<void> updateLocationLog({
    required int id,
    DateTime? logDateTime,
    String? status,
    String? countryCode,
  }) async {
    log(
      "📝 Updating location log with ID: $id",
      name: 'LocationLogsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      final companionBuilder = LocationLogsCompanion(
        logDateTime:
            logDateTime != null ? Value(logDateTime) : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        countryCode:
            countryCode != null ? Value(countryCode) : const Value.absent(),
      );

      await (database.update(database.locationLogs)
            ..where((log) => log.id.equals(id)))
          .write(companionBuilder);

      log(
        "✅ Successfully updated location log with ID: $id",
        name: 'LocationLogsRepository',
        level: 1,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while updating location log: $e",
        name: 'LocationLogsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Delete all logs for a specific country code
  Future<void> deleteLogsByCountryCode(String countryCode) async {
    log(
      "🗑️ Deleting all location logs for country: $countryCode",
      name: 'LocationLogsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      // Delete all logs for this country code
      await (database.delete(database.locationLogs)
            ..where((log) => log.countryCode.equals(countryCode)))
          .go();

      log(
        "✅ Successfully deleted all location logs for country: $countryCode",
        name: 'LocationLogsRepository',
        level: 1,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while deleting location logs: $e",
        name: 'LocationLogsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }
}
