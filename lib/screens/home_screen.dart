import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:location_tracker/app_initializer.dart';
import 'entries_screen.dart';
import 'logs_screen.dart';
import '../services/location_service.dart';
import '../services/country_service.dart';
import '../services/log_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Services
  late CountryService _countryService;
  late LogService _logService;
  
  int _selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize database services
      _countryService = CountryService(database);
      _logService = LogService(database);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error initializing services: $e');
      // Handle error appropriately
    }
  }

  Future<void> _addCountry() async {
    try {
      String? country = await LocationService.getCurrentCountry();
      if (country != null && mounted) {
        // Use instance methods instead of static methods
        await _countryService.saveCountryVisit(country);

        // Log success entry using LogService instance
        await _logService.logEntry(status: 'success', countryCode: country);

        setState(() {}); // Refresh UI
      } else {
        // Log error entry using LogService instance
        await _logService.logEntry(status: 'error');
      }
    } catch (e) {
      // Log exception using LogService instance
      await _logService.logEntry(status: 'error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding country: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> screens = [
      EntriesScreen(countryService: _countryService),
      LogsScreen(logService: _logService),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: screens),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Entries"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Logs"),
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