import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'country_visits.dart';
import 'location_logs.dart';
import 'connection_helper.dart';

part 'database.g.dart'; // Ensure this is correctly pointing to the generated file

@DriftDatabase(tables: [CountryVisits, LocationLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}