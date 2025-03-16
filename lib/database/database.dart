import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Define tables
class CountryVisits extends Table {
  TextColumn get countryCode => text()();
  DateTimeColumn get entryDate => dateTime()();
  IntColumn get daysSpent => integer()();

  @override
  Set<Column> get primaryKey => {countryCode};
}

class LocationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get logDateTime => dateTime()();
  TextColumn get status => text()();
  TextColumn get countryCode => text().nullable()();
}

// Define the database
@DriftDatabase(tables: [CountryVisits, LocationLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  
  // Country Visit methods
  Future<void> saveCountryVisit(String countryCode) async {
    final today = DateTime.now();
    final formattedToday = DateTime(today.year, today.month, today.day);
    
    // Check if there's an existing entry for this country
    final existingVisit = await (select(countryVisits)
      ..where((t) => t.countryCode.equals(countryCode)))
      .getSingleOrNull();
      
    if (existingVisit != null) {
      // If the user is still in the same country, just update the days spent
      if (existingVisit.entryDate != formattedToday) {
        await (update(countryVisits)..where((t) => t.countryCode.equals(countryCode)))
          .write(CountryVisitsCompanion(
            entryDate: Value(formattedToday),
            daysSpent: Value(existingVisit.daysSpent + 1),
          ));
      }
    } else {
      // If it's a new country, add a new entry
      await into(countryVisits).insert(
        CountryVisitsCompanion.insert(
          countryCode: countryCode,
          entryDate: formattedToday,
          daysSpent: 1,
        ),
      );
    }
  }
  
  // Get all country visits
  Future<List<CountryVisit>> getAllVisits() {
    return select(countryVisits).get();
  }
  
  // Log methods
  Future<void> logEntry({required String status, String? countryCode}) async {
    await into(locationLogs).insert(
      LocationLogsCompanion.insert(
        logDateTime: DateTime.now(),  // Using logDateTime to match the table definition
        status: status,
        countryCode: Value(countryCode),
      ),
    );
  }
}

// Connection helper
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'traveler_app.db'));
    return NativeDatabase(file);
  });
}