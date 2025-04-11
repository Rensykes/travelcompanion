import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:trackie/data/datasource/database.dart';

class CountryVisitsRepository {
  final AppDatabase database;

  CountryVisitsRepository(this.database);

  // Save or update country visit
  Future<void> saveCountryVisit(String countryCode) async {
    log(
      '🌍 Starting to save/update country visit for: $countryCode',
      name: 'CountryVisitsRepository',
      level: 0, // 0 for INFO
      time: DateTime.now(),
    );

    final today = DateTime.now();
    final formattedToday = DateTime(today.year, today.month, today.day);

    // Check if there's an existing entry for this country
    final existingVisit = await (database.select(database.countryVisits)
          ..where((t) => t.countryCode.equals(countryCode)))
        .getSingleOrNull();

    if (existingVisit != null) {
      log(
        "📝 Found existing visit for $countryCode with ${existingVisit.daysSpent} days spent",
        name: 'CountryVisitsRepository',
        level: 0,
        time: DateTime.now(),
      );
      // If the user is still in the same country, just update the days spent
      if (existingVisit.entryDate != formattedToday) {
        log(
          "📅 Updating days spent for $countryCode from ${existingVisit.daysSpent} to ${existingVisit.daysSpent + 1}",
          name: 'CountryVisitsRepository',
          level: 0,
          time: DateTime.now(),
        );
        await (database.update(database.countryVisits)
              ..where((t) => t.countryCode.equals(countryCode)))
            .write(
          CountryVisitsCompanion(
            entryDate: Value(formattedToday),
            daysSpent: Value(existingVisit.daysSpent + 1),
          ),
        );
        log(
          "✅ Successfully updated country visit for $countryCode",
          name: 'CountryVisitsRepository',
          level: 1, // 1 for SUCCESS
          time: DateTime.now(),
        );
      } else {
        log(
          "ℹ️ No update needed for $countryCode - already logged today",
          name: 'CountryVisitsRepository',
          level: 0,
          time: DateTime.now(),
        );
      }
    } else {
      log(
        "✨ Creating new country visit entry for $countryCode",
        name: 'CountryVisitsRepository',
        level: 0,
        time: DateTime.now(),
      );
      // If it's a new country, add a new entry
      await database.into(database.countryVisits).insert(
            CountryVisitsCompanion.insert(
              countryCode: countryCode,
              entryDate: formattedToday,
              daysSpent: 1,
            ),
          );
      log(
        "✅ Successfully created new country visit for $countryCode",
        name: 'CountryVisitsRepository',
        level: 1,
        time: DateTime.now(),
      );
    }
  }

  // Save country visit with a specific date
  Future<void> saveCountryVisitWithDate(
      String countryCode, DateTime date) async {
    log(
      '🌍 Saving country visit for: $countryCode with specific date: $date',
      name: 'CountryVisitsRepository',
      level: 0, // 0 for INFO
      time: DateTime.now(),
    );

    final formattedDate = DateTime(date.year, date.month, date.day);

    // Check if there's an existing entry for this country
    final existingVisit = await (database.select(database.countryVisits)
          ..where((t) => t.countryCode.equals(countryCode)))
        .getSingleOrNull();

    if (existingVisit != null) {
      log(
        "📝 Found existing visit for $countryCode, updating with new date",
        name: 'CountryVisitsRepository',
        level: 0,
        time: DateTime.now(),
      );

      // Update the existing entry with the new date
      await (database.update(database.countryVisits)
            ..where((t) => t.countryCode.equals(countryCode)))
          .write(
        CountryVisitsCompanion(
          entryDate: Value(formattedDate),
          // Keep the days spent value
          daysSpent: Value(existingVisit.daysSpent + 1),
        ),
      );

      log(
        "✅ Successfully updated country visit for $countryCode with new date",
        name: 'CountryVisitsRepository',
        level: 1, // 1 for SUCCESS
        time: DateTime.now(),
      );
    } else {
      log(
        "✨ Creating new country visit entry for $countryCode with specified date",
        name: 'CountryVisitsRepository',
        level: 0,
        time: DateTime.now(),
      );

      // If it's a new country, add a new entry with the specified date
      await database.into(database.countryVisits).insert(
            CountryVisitsCompanion.insert(
              countryCode: countryCode,
              entryDate: formattedDate,
              daysSpent: 1,
            ),
          );

      log(
        "✅ Successfully created new country visit for $countryCode with date $formattedDate",
        name: 'CountryVisitsRepository',
        level: 1,
        time: DateTime.now(),
      );
    }
  }

  // Get all country visits
  Future<List<CountryVisit>> getAllVisits() async {
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

  // Delete a country visit and all related data by its country code
  Future<void> deleteCountryVisit(String countryCode) async {
    log(
      "🗑️ Starting to delete all data for country: $countryCode",
      name: 'CountryVisitsRepository',
      level: 0,
      time: DateTime.now(),
    );

    try {
      // Start a transaction to ensure all deletions are atomic
      await database.transaction(() async {
        // First, get all location logs for this country
        final locationLogs = await (database.select(database.locationLogs)
              ..where((log) => log.countryCode.equals(countryCode)))
            .get();

        // Delete all relations for these location logs
        for (final log in locationLogs) {
          await (database.delete(database.logCountryRelations)
                ..where((relation) => relation.logId.equals(log.id)))
              .go();
        }

        // Delete all location logs for this country
        await (database.delete(database.locationLogs)
              ..where((log) => log.countryCode.equals(countryCode)))
            .go();

        // Finally, delete the country visit
        await (database.delete(database.countryVisits)
              ..where((visit) => visit.countryCode.equals(countryCode)))
            .go();
      });

      log(
        "✅ Successfully deleted all data for country: $countryCode",
        name: 'CountryVisitsRepository',
        level: 1, // 1 for SUCCESS
        time: DateTime.now(),
      );
    } catch (e) {
      log(
        "❌ Error while deleting country data: $e",
        name: 'CountryVisitsRepository',
        level: 3, // 3 for ERROR
        time: DateTime.now(),
        error: e,
      );
      rethrow; // Rethrow to handle in the UI
    }
  }
}
