import 'package:trackie/data/datasource/database.dart';

class CalendarDayData {
  final String countryCode;
  final DateTime firstSeenTime;
  final List<LocationLog> logEntries;

  CalendarDayData({
    required this.countryCode,
    required this.firstSeenTime,
    required this.logEntries,
  });
}
