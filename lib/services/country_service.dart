import 'dart:developer';
import '../database/database.dart';

class CountryService {
  final AppDatabase database;

  CountryService(this.database);

  // Save or update country visit
  Future<void> saveCountryVisit(String countryCode) async {
    log("Country Visit");
    await database.saveCountryVisit(countryCode);
  }

  // Get all country visits
  Future<List<CountryVisit>> getAllVisits() async {
    return await database.getAllVisits();
  }
}