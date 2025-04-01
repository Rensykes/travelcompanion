import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/database/provider/database_provider.dart';

part 'location_logs.g.dart';

@riverpod
LocationLogsRepository locationLogsRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return LocationLogsRepository(database);
}

@riverpod
Stream<List<LocationLog>> allLogs(Ref ref) {
  final repository = ref.watch(locationLogsRepositoryProvider);
  return repository.watchAllLogs();
}

@riverpod
Future<List<LocationLog>> filteredLogs(Ref ref, {required bool showErrorLogs}) async {
  final allLogs = await ref.watch(locationLogsRepositoryProvider).getAllLogs();
  if (showErrorLogs) {
    return allLogs; 
  } else {
    return allLogs.where((log) => log.status != "error").toList();
  }
}

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
      // First get the log to be deleted to know its country code
      final logToDelete = await (database.select(database.locationLogs)
        ..where((log) => log.id.equals(id))).getSingleOrNull();
      
      if (logToDelete == null) {
        log("⚠️ Log not found for deletion: ID - $id");
        return;
      }
      
      String? affectedCountryCode = logToDelete.countryCode;
      
      // Delete related entries in logCountryRelations
      await (database.delete(database.logCountryRelations)
        ..where((relation) => relation.logId.equals(id))).go();

      // Delete the actual log entry
      await (database.delete(database.locationLogs)
        ..where((log) => log.id.equals(id))).go();

      log("🗑️ Log Deleted: ID - $id and its relations");
      
      // Recalculate daysSpent for the affected country if there was one
      if (affectedCountryCode != null) {
        await recalculateDaysSpent(affectedCountryCode);
      }
    } catch (e) {
      log("❌ Error while deleting log: $e");
    }
  }
  
  /// Recalculate the daysSpent value for a country based on LocationLogs
  Future<void> recalculateDaysSpent(String countryCode) async {
    try {
      // Get all logs for this country
      final logs = await getRelationsForCountryVisit(countryCode);
      
      if (logs.isEmpty) {
        // If no logs left, delete the country visit record
        await (database.delete(database.countryVisits)
          ..where((visit) => visit.countryCode.equals(countryCode))).go();
        log("🌎 Country visit removed for $countryCode since no logs remain");
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
      
      // Update the country visit with the new values
      await (database.update(database.countryVisits)
        ..where((visit) => visit.countryCode.equals(countryCode))).write(
          CountryVisitsCompanion(
            entryDate: Value(entryDate),
            daysSpent: Value(uniqueDates.length),
          ),
        );
      
      log("🔄 Recalculated days spent for $countryCode: ${uniqueDates.length} days");
    } catch (e) {
      log("❌ Error while recalculating days spent: $e");
    }
  }
}