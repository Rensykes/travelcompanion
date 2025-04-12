import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:trackie/data/datasource/database.dart';

class LogCountryRelationsRepository {
  final AppDatabase database;

  LogCountryRelationsRepository(this.database);

  /// Create a new relation between log and country
  Future<void> createRelation({
    required int logId,
    required String countryCode,
  }) async {
    log(
      "🔗 Creating relation between log $logId and country $countryCode",
      name: 'LogCountryRelationsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      await database.into(database.logCountryRelations).insert(
            LogCountryRelationsCompanion.insert(
              logId: logId,
              countryCode: countryCode,
            ),
          );

      log(
        "✅ Successfully created relation between log $logId and country $countryCode",
        name: 'LogCountryRelationsRepository',
        level: 1,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while creating log-country relation: $e",
        name: 'LogCountryRelationsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Get all relations for a country
  Future<List<LogCountryRelation>> getRelationsByCountryCode(
      String countryCode) async {
    log(
      "🔍 Fetching relations for country: $countryCode",
      name: 'LogCountryRelationsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      final relations = await (database.select(database.logCountryRelations)
            ..where((r) => r.countryCode.equals(countryCode)))
          .get();

      log(
        "📊 Retrieved ${relations.length} relations for country $countryCode",
        name: 'LogCountryRelationsRepository',
        level: 0,
        time: DateTime.now(),
      );

      return relations;
    } catch (e) {
      log(
        "❌ Error while fetching relations: $e",
        name: 'LogCountryRelationsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Get all relations for a log
  Future<List<LogCountryRelation>> getRelationsByLogId(int logId) async {
    log(
      "🔍 Fetching relations for log ID: $logId",
      name: 'LogCountryRelationsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      final relations = await (database.select(database.logCountryRelations)
            ..where((r) => r.logId.equals(logId)))
          .get();

      log(
        "📊 Retrieved ${relations.length} relations for log ID $logId",
        name: 'LogCountryRelationsRepository',
        level: 0,
        time: DateTime.now(),
      );

      return relations;
    } catch (e) {
      log(
        "❌ Error while fetching relations: $e",
        name: 'LogCountryRelationsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Delete relations for a log
  Future<void> deleteRelationsByLogId(int logId) async {
    log(
      "🗑️ Deleting relations for log ID: $logId",
      name: 'LogCountryRelationsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      await (database.delete(database.logCountryRelations)
            ..where((relation) => relation.logId.equals(logId)))
          .go();

      log(
        "✅ Successfully deleted relations for log ID: $logId",
        name: 'LogCountryRelationsRepository',
        level: 1,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while deleting relations: $e",
        name: 'LogCountryRelationsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Delete relations for a country
  Future<void> deleteRelationsByCountryCode(String countryCode) async {
    log(
      "🗑️ Deleting relations for country: $countryCode",
      name: 'LogCountryRelationsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      await (database.delete(database.logCountryRelations)
            ..where((relation) => relation.countryCode.equals(countryCode)))
          .go();

      log(
        "✅ Successfully deleted relations for country: $countryCode",
        name: 'LogCountryRelationsRepository',
        level: 1,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while deleting relations: $e",
        name: 'LogCountryRelationsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }

  /// Get logs for a country with join
  Future<List<LocationLog>> getLogsByCountryCodeJoin(String countryCode) async {
    log(
      "🔍 Fetching logs for country via join: $countryCode",
      name: 'LogCountryRelationsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
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
        "📊 Retrieved ${logs.length} logs for country $countryCode via join",
        name: 'LogCountryRelationsRepository',
        level: 0,
        time: DateTime.now(),
      );

      return logs;
    } catch (e) {
      log(
        "❌ Error while fetching logs via join: $e",
        name: 'LogCountryRelationsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }
}
