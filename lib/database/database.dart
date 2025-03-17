import 'package:drift/drift.dart';
import 'log_country_relations.dart';
import 'country_visits.dart';
import 'location_logs.dart';
import 'connection_helper.dart';

part 'database.g.dart'; // Ensure this is correctly pointing to the generated file

@DriftDatabase(tables: [CountryVisits, LocationLogs, LogCountryRelations])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}