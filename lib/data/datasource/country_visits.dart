import 'package:drift/drift.dart';

class CountryVisits extends Table {
  TextColumn get countryCode => text()();
  DateTimeColumn get entryDate => dateTime()();
  IntColumn get daysSpent => integer()();

  @override
  Set<Column> get primaryKey => {countryCode};
}
