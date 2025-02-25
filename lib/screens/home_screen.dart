import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'entries_screen.dart';
import 'chart_screen.dart';
import 'calendar_screen.dart';
import '../db/country_adapter.dart';
import '../services/location_service.dart';
import '../services/country_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Box<CountryVisit>? box;
  int _selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      // Make sure the box is open
      if (!Hive.isBoxOpen('country_visits')) {
        box = await Hive.openBox<CountryVisit>('country_visits');
      } else {
        box = Hive.box<CountryVisit>('country_visits');
      }
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error initializing box: $e');
      // Handle error appropriately
    }
  }

  Future<void> _addCountry() async {
    try {
      String? country = await LocationService.getCurrentCountry();
      if (country != null && mounted && box != null) {
        await CountryService.saveCountryVisit(country);
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding country: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || box == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> screens = [
      EntriesScreen(box: box!),
      ChartScreen(box: box!),
      CalendarScreen(box: box!),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Entries"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Charts"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar"),
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