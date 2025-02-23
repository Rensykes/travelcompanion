import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:table_calendar/table_calendar.dart';
import '../db/country_adapter.dart';

class CountryCalendar extends StatefulWidget {
  final Box<CountryVisit> box;

  const CountryCalendar({super.key, required this.box});

  @override
  _CountryCalendarState createState() => _CountryCalendarState();
}

class _CountryCalendarState extends State<CountryCalendar> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  Map<DateTime, String> _events = {};

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = null;
    _loadEvents();
  }

  void _loadEvents() {
    Map<DateTime, String> events = {};
    for (var visit in widget.box.values) {
      DateTime date = DateTime(visit.entryDate.year, visit.entryDate.month, visit.entryDate.day);
      events[date] = visit.countryCode;
    }
    setState(() {
      _events = events;
    });
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

              String? country = _events[selectedDay];
              if (country != null && mounted) { // 🔥 Avoid calling after dispose
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("📍 You were in $country on ${selectedDay.toLocal()}")),
                );
              }
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                String? country = _events[date];
                if (country != null) {
                  return Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          country,
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
