import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:trackie/data/datasource/database.dart';

class CountryVisitsRepository {
  final AppDatabase database;

  CountryVisitsRepository(this.database);

  // Save or update country visit
  Future<void> saveCountryVisit(String countryCode) async {
    log("🌍 Starting to save/update country visit for: $countryCode");

    final today = DateTime.now();
    final formattedToday = DateTime(today.year, today.month, today.day);

    // Check if there's an existing entry for this country
    final existingVisit = await (database.select(database.countryVisits)
          ..where((t) => t.countryCode.equals(countryCode)))
        .getSingleOrNull();

    if (existingVisit != null) {
      log(
        "📝 Found existing visit for $countryCode with ${existingVisit.daysSpent} days spent",
      );
      // If the user is still in the same country, just update the days spent
      if (existingVisit.entryDate != formattedToday) {
        log(
          "📅 Updating days spent for $countryCode from ${existingVisit.daysSpent} to ${existingVisit.daysSpent + 1}",
        );
        await (database.update(database.countryVisits)
              ..where((t) => t.countryCode.equals(countryCode)))
            .write(
          CountryVisitsCompanion(
            entryDate: Value(formattedToday),
            daysSpent: Value(existingVisit.daysSpent + 1),
          ),
        );
        log("✅ Successfully updated country visit for $countryCode");
      } else {
        log("ℹ️ No update needed for $countryCode - already logged today");
      }
    } else {
      log("✨ Creating new country visit entry for $countryCode");
      // If it's a new country, add a new entry
      await database.into(database.countryVisits).insert(
            CountryVisitsCompanion.insert(
              countryCode: countryCode,
              entryDate: formattedToday,
              daysSpent: 1,
            ),
          );
      log("✅ Successfully created new country visit for $countryCode");
    }
  }

  // Get all country visits
  Future<List<CountryVisit>> getAllVisits() async {
    log("📋 Fetching all country visits");
    final visits = await database.select(database.countryVisits).get();
    log("📊 Retrieved ${visits.length} country visits");
    return visits;
  }

  // Delete a country visit and all related data by its country code
  Future<void> deleteCountryVisit(String countryCode) async {
    log("🗑️ Starting to delete all data for country: $countryCode");
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

      log("✅ Successfully deleted all data for country: $countryCode");
    } catch (e) {
      log("❌ Error while deleting country data: $e");
      rethrow; // Rethrow to handle in the UI
    }
  }
}
