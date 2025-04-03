import 'package:drift/drift.dart';

class LocationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get logDateTime => dateTime()();
  TextColumn get status => text()();
  TextColumn get countryCode => text().nullable()();
}
