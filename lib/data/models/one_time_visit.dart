import 'package:equatable/equatable.dart';
import 'package:trackie/data/datasource/database.dart';

/// Represents a continuous visit to a country, with entry and exit dates.
///
/// This class is used to track when a user enters and exits a country,
/// allowing for historical tracking of travel between countries.
class OneTimeVisit extends Equatable {
  /// The country code (e.g., 'US', 'GB', 'FR')
  final String countryCode;

  /// The date when the user entered the country
  final DateTime entryDate;

  /// The date when the user exited the country. Null if still in the country.
  final DateTime? exitDate;

  /// List of location logs recorded during this visit
  final List<LocationLog> locationLogs;

  const OneTimeVisit({
    required this.countryCode,
    required this.entryDate,
    this.exitDate,
    required this.locationLogs,
  });

  /// The duration of the visit in days
  int get daysSpent {
    if (exitDate == null) {
      // If still in the country, calculate days until now
      final now = DateTime.now();
      return now.difference(entryDate).inDays +
          1; // +1 to include the current day
    }

    return exitDate!.difference(entryDate).inDays +
        1; // +1 to include both entry and exit days
  }

  /// Whether the visit is current (no exit date)
  bool get isCurrent => exitDate == null;

  @override
  List<Object?> get props => [countryCode, entryDate, exitDate, locationLogs];
}
