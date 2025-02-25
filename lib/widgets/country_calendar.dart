import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:table_calendar/table_calendar.dart';
import '../db/location_log.dart';  // Import the LocationLog model

class CountryCalendar extends StatefulWidget {
  final Box<LocationLog> box;

  const CountryCalendar({super.key, required this.box});

  @override
  _CountryCalendarState createState() => _CountryCalendarState();
}

class _CountryCalendarState extends State<CountryCalendar> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  // Modified _events to store multiple countries per day
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = null;
    _loadEvents();
  }

  void _loadEvents() async {
    Map<DateTime, List<String>> events = {};

    // Use asynchronous loading to avoid blocking the UI thread
    await Future.delayed(Duration(milliseconds: 100)); // Simulate async load
    for (var log in widget.box.values) {
      // Only add logs with a successful status and a country code
      if (log.status == "success" && log.countryCode != null) {
        DateTime date = DateTime(log.dateTime.year, log.dateTime.month, log.dateTime.day);
        if (!events.containsKey(date)) {
          events[date] = [];
        }
        events[date]!.add(log.countryCode!); // Add country to list
      }
    }

    if (mounted) {
      setState(() {
        _events = events;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // 🔥 Fix overflow
      child: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              //FIXME snackbar does not appear?
              // Check if there are events for the selected day and show the Snackbar
              List<String>? countries = _events[selectedDay];
              if (countries != null && countries.isNotEmpty && mounted) { // 🔥 Avoid calling after dispose
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("📍 You were in ${countries.join(', ')} on ${selectedDay.toLocal()}")),
                );
              }
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                List<String>? countries = _events[date];
                if (countries != null && countries.isNotEmpty) {
                  return Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          countries.join(', '), // Show all countries for this day
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
