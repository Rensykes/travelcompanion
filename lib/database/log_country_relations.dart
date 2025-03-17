import 'package:drift/drift.dart';
import 'package:trackie/database/country_visits.dart';
import 'package:trackie/database/location_logs.dart';

class LogCountryRelations extends Table {
  IntColumn get logId => integer().references(LocationLogs, #id)();
  TextColumn get countryCode => text().references(CountryVisits, #countryCode)();

  @override
  Set<Column> get primaryKey => {logId, countryCode};
}
