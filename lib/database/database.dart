import 'package:drift/drift.dart';
import 'country_visits.dart';
import 'location_logs.dart';
import 'connection_helper.dart';

part 'database.g.dart'; // Ensure this is correctly pointing to the generated file

@DriftDatabase(tables: [CountryVisits, LocationLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

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
        logDateTime: DateTime.now(), // Using logDateTime to match the table definition
        status: status,
        countryCode: Value(countryCode),
      ),
    );
  }
}