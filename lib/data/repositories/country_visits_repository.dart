import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:trackie/data/datasource/database.dart';

class CountryVisitsRepository {
  final AppDatabase database;

  CountryVisitsRepository(this.database);

  // Save or update country visit
  Future<void> saveCountryVisit(String countryCode) async {
    log("Country Visit");

    final today = DateTime.now();
    final formattedToday = DateTime(today.year, today.month, today.day);

    // Check if there's an existing entry for this country
    final existingVisit =
        await (database.select(database.countryVisits)
          ..where((t) => t.countryCode.equals(countryCode))).getSingleOrNull();

    if (existingVisit != null) {
      // If the user is still in the same country, just update the days spent
      if (existingVisit.entryDate != formattedToday) {
        await (database.update(database.countryVisits)
          ..where((t) => t.countryCode.equals(countryCode))).write(
          CountryVisitsCompanion(
            entryDate: Value(formattedToday),
            daysSpent: Value(existingVisit.daysSpent + 1),
          ),
        );
      }
    } else {
      // If it's a new country, add a new entry
      await database
          .into(database.countryVisits)
          .insert(
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
    return database.select(database.countryVisits).get();
  }

  // Watch all country visits as a stream for reactive UI updates
  Stream<List<CountryVisit>> watchAllVisits() {
    return database.select(database.countryVisits).watch();
  }

  // Delete a country visit by its country code
  Future<void> deleteCountryVisit(String countryCode) async {
    try {
      // Delete the country visit
      await (database.delete(database.countryVisits)
        ..where((visit) => visit.countryCode.equals(countryCode))).go();

      log("🗑️ Country Visit Deleted: $countryCode");
    } catch (e) {
      log("❌ Error while deleting country visit: $e");
      rethrow; // Rethrow to handle in the UI
    }
  }
}
