import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:location_tracker/db/location_log.dart';
import 'entries_screen.dart';
import 'chart_screen.dart';
import 'calendar_screen.dart';
import 'logs_screen.dart';
import '../db/country_adapter.dart';
import '../services/location_service.dart';
import '../services/country_service.dart';
import '../services/log_service.dart';
import '../utils/hive_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Box<CountryVisit>? countryVisitBox;
  Box<LocationLog>? locationLogsBox;
  int _selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeBoxes();
  }

  Future<void> _initializeBoxes() async {
    try {
      // Open country visits box
      if (!Hive.isBoxOpen(countryVisitsBoxName)) {
        countryVisitBox = await Hive.openBox<CountryVisit>(countryVisitsBoxName);
      } else {
        countryVisitBox = Hive.box<CountryVisit>(countryVisitsBoxName);
      }

      // Open location logs box
      if (!Hive.isBoxOpen(locationLogsBoxName)) {
        locationLogsBox = await Hive.openBox(locationLogsBoxName);
      } else {
        locationLogsBox = Hive.box(locationLogsBoxName);
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error initializing boxes: $e');
      // Handle error appropriately
    }
  }

Future<void> _addCountry() async {
  try {
    String? country = await LocationService.getCurrentCountry();
    if (country != null && mounted && countryVisitBox != null) {
      await CountryService.saveCountryVisit(country);

      // ✅ Log success entry using LogService
      await LogService.logEntry(status: logStatusSuccess, countryCode: country);

      setState(() {}); // Refresh UI
    } else {
      // ❌ Log error entry using LogService
      await LogService.logEntry(status: logStatusError);
    }
  } catch (e) {
    // ❌ Log exception using LogService
    await LogService.logEntry(status: logStatusError);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding country: ${e.toString()}')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    if (isLoading || countryVisitBox == null || locationLogsBox == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> screens = [
      EntriesScreen(box: countryVisitBox!),
      ChartScreen(box: countryVisitBox!),
      CalendarScreen(box: locationLogsBox!),
      LogsScreen(box: locationLogsBox!), // Add LogsScreen
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: screens),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor:Colors.white, // Ensures the background is not transparent
        selectedItemColor: Colors.blue, // Set the selected icon/text color
        unselectedItemColor: Colors.grey, // Set the unselected icon/text color
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Entries"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Charts"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar",),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Logs",), // New tab
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCountry,
        tooltip: 'Add Current Location',
        child: const Icon(Icons.add_location),
      ),
    );
  }
}
