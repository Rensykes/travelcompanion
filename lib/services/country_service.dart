import 'package:hive/hive.dart';
import '../db/country_adapter.dart';

class CountryService {
  static const String boxName = "country_visits";

  // Open the Hive box
  static Future<Box<CountryVisit>> _openBox() async {
    return await Hive.openBox<CountryVisit>(boxName);
  }

  // Save or update country visit
  static Future<void> saveCountryVisit(String countryCode) async {
    final box = await _openBox();
    final today = DateTime.now();
    final formattedToday = DateTime(today.year, today.month, today.day);

    // Check if the last stored country is different
    if (box.isNotEmpty) {
      CountryVisit lastVisit = box.values.last;

      // If the user is still in the same country, just update the days spent
      if (lastVisit.countryCode == countryCode) {
        if (lastVisit.entryDate != formattedToday) {
          lastVisit.daysSpent += 1;
          lastVisit.entryDate = formattedToday;
          await box.put(lastVisit.countryCode, lastVisit);
        }
        return;
      }
    }

    // If it's a new country, add a new entry
    final newVisit = CountryVisit(
      countryCode: countryCode,
      entryDate: formattedToday,
      daysSpent: 1,
    );

    await box.put(countryCode, newVisit);
  }

  // Get all country visits
  static Future<List<CountryVisit>> getAllVisits() async {
    final box = await _openBox();
    return box.values.toList();
  }
}
