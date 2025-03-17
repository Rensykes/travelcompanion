import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:location_tracker/utils/app_initializer.dart';
import 'entries_screen.dart';
import 'logs_screen.dart';
import '../services/location_service.dart';
import '../repositories/country_visits.dart';
import '../repositories/location_logs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Services
  late CountryVisitsRepository _countryService;
  late LocationLogsRepository _logService;

  int _selectedIndex = 0;
  bool isLoading = true;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize database services
      _countryService = CountryVisitsRepository(database);
      _logService = LocationLogsRepository(database);

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
    if (mounted) {
      setState(() {
        _isFetchingLocation = true; // Start loading
      });
    }

    try {
      String? country = await LocationService.getCurrentCountry();
      if (country != null && mounted) {
        // Use instance methods instead of static methods
        await _countryService.saveCountryVisit(country);
        await _logService.logEntry(status: 'success', countryCode: country);

        // Show alert dialog with country info
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("Location Retrieved"),
                  content: Text("You are currently in: $country"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("OK"),
                    ),
                  ],
                ),
          );
        }
      } else {
        await _logService.logEntry(status: 'error');
      }
    } catch (e) {
      await _logService.logEntry(status: 'error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding country: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false; // Stop loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> screens = [
      EntriesScreen(
        countryService: CountryVisitsRepository(database),
        locationLogsRepository: LocationLogsRepository(database),
      ),
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
        onPressed:
            _isFetchingLocation ? null : _addCountry, // Disable when loading
        tooltip: 'Add Current Location',
        child:
            _isFetchingLocation
                ? const CircularProgressIndicator(
                  color: Colors.white,
                ) // Show loading
                : const Icon(Icons.add_location),
      ),
    );
  }
}
