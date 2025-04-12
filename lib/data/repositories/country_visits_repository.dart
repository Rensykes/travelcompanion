import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:trackie/data/datasource/database.dart';

class CountryVisitsRepository {
  final AppDatabase database;

  CountryVisitsRepository(this.database);

  // Get a country visit by country code
  Future<CountryVisit?> getVisitByCountryCode(String countryCode) async {
    log(
      "🔍 Fetching country visit for: $countryCode",
      name: 'CountryVisitsRepository',
      level: 0,
      time: DateTime.now(),
    );

    final visit = await (database.select(database.countryVisits)
          ..where((t) => t.countryCode.equals(countryCode)))
        .getSingleOrNull();

    return visit;
  }

  // Create a new country visit
  Future<void> createCountryVisit({
    required String countryCode,
    required DateTime entryDate,
    required int daysSpent,
  }) async {
    log(
      "✨ Creating new country visit entry for $countryCode",
      name: 'CountryVisitsRepository',
      level: 0,
      time: DateTime.now(),
    );

    await database.into(database.countryVisits).insert(
          CountryVisitsCompanion.insert(
            countryCode: countryCode,
            entryDate: entryDate,
            daysSpent: daysSpent,
          ),
        );

    log(
      "✅ Successfully created new country visit for $countryCode",
      name: 'CountryVisitsRepository',
      level: 1,
      time: DateTime.now(),
    );
  }

  // Update an existing country visit
  Future<void> updateCountryVisit({
    required String countryCode,
    DateTime? entryDate,
    int? daysSpent,
  }) async {
    log(
      "📝 Updating country visit for: $countryCode",
      name: 'CountryVisitsRepository',
      level: 0,
      time: DateTime.now(),
    );

    final companionBuilder = CountryVisitsCompanion(
      entryDate: entryDate != null ? Value(entryDate) : const Value.absent(),
      daysSpent: daysSpent != null ? Value(daysSpent) : const Value.absent(),
    );

    await (database.update(database.countryVisits)
          ..where((t) => t.countryCode.equals(countryCode)))
        .write(companionBuilder);

    log(
      "✅ Successfully updated country visit for $countryCode",
      name: 'CountryVisitsRepository',
      level: 1,
      time: DateTime.now(),
    );
  }

  // Get all country visits
  Future<List<CountryVisit>> getAllCountryVisits() async {
    log(
      "📋 Fetching all country visits",
      name: 'CountryVisitsRepository',
      level: 0,
      time: DateTime.now(),
    );

    final visits = await database.select(database.countryVisits).get();

    log(
      "📊 Retrieved ${visits.length} country visits",
      name: 'CountryVisitsRepository',
      level: 0,
      time: DateTime.now(),
    );

    return visits;
  }

  // Delete a country visit by its country code
  Future<void> deleteCountryVisit(String countryCode) async {
    log(
      "🗑️ Deleting country visit: $countryCode",
      name: 'CountryVisitsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      await (database.delete(database.countryVisits)
            ..where((visit) => visit.countryCode.equals(countryCode)))
          .go();

      log(
        "✅ Successfully deleted country visit for $countryCode",
        name: 'CountryVisitsRepository',
        level: 1,
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while deleting country visit: $e",
        name: 'CountryVisitsRepository',
        level: 3,
        time: DateTime.now(),
        error: e,
      );
      rethrow;
    }
  }
}
