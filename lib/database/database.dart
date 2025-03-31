import 'package:drift/drift.dart';
import 'package:trackie/database/log_country_relations.dart';
import 'package:trackie/database/country_visits.dart';
import 'package:trackie/database/location_logs.dart';
import 'package:trackie/database/connection_helper.dart';

part 'database.g.dart'; // Ensure this is correctly pointing to the generated file


@DriftDatabase(tables: [CountryVisits, LocationLogs, LogCountryRelations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Run when the database is first created
    onCreate: (Migrator m) async {
      // Creating the table for log_country_relations
      await m.createAll();
    },
    // Run when the database schema is upgraded (e.g., when the version is bumped)
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // This is where you handle the logic to create missing tables or columns
        await m.createTable(logCountryRelations);
      }
    },
  );
}
