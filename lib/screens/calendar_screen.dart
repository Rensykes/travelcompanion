import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widgets/country_calendar.dart';
import '../db/country_adapter.dart';

// Displays a calendar with country visits.
class CalendarScreen extends StatelessWidget {
  final Box<CountryVisit> box;
  const CalendarScreen({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return CountryCalendar(box: box);
  }
}
