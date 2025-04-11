import 'package:trackie/data/datasource/database.dart';

class CalendarDayData {
  final Set<String> countryCodes;
  final Map<String, DateTime> firstSeenTimes;
  final List<LocationLog> logEntries;

  CalendarDayData({
    required this.countryCodes,
    required this.firstSeenTimes,
    required this.logEntries,
  });
}
