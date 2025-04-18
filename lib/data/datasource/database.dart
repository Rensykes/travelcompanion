import 'package:drift/drift.dart';
import 'package:trackie/data/datasource/log_country_relations.dart';
import 'package:trackie/data/datasource/country_visits.dart';
import 'package:trackie/data/datasource/location_logs.dart';
import 'package:trackie/data/datasource/connection_helper.dart';

part 'database.g.dart'; // Ensure this is correctly pointing to the generated file

// TODO: https://github.com/simolus3/drift/issues/1470#issuecomment-2773180895 sqlite not removed always after the app is uninstalled
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
