import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:location_tracker/db/location_log.dart';
import '../widgets/country_calendar.dart';

// Displays a calendar with country visits.
class CalendarScreen extends StatelessWidget {
  final Box<LocationLog> box;
  const CalendarScreen({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return CountryCalendar(box: box);
  }
}
