import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:trackie/repositories/country_visits.dart';
import 'package:trackie/services/country_visit_data_service.dart';
import 'package:trackie/services/sim_info_service.dart';
import 'package:trackie/utils/app_initializer.dart';
import 'package:trackie/screens/entries_screen.dart';
import 'package:trackie/screens/logs_screen.dart';
import 'package:trackie/repositories/location_logs.dart';
import 'package:trackie/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool isDark, bool useSystemTheme) onThemeChanged;
  final bool isDarkMode;
  final bool useSystemTheme;

  const HomeScreen({
    super.key, 
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.useSystemTheme,
  });

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  CountryVisitsRepository? _countryVisitsRepository;
  LocationLogsRepository? _locationLogsRepository;
  CountryDataService? _countryDataService;

  int _selectedIndex = 0;
  bool isLoading = true;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() => _initializeServices());
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize database services
      _countryVisitsRepository = CountryVisitsRepository(database);
      _locationLogsRepository = LocationLogsRepository(database);

      // Initialize Data Service
      _countryDataService = CountryDataService(
        locationLogsRepository: _locationLogsRepository!,
        countryVisitsRepository: _countryVisitsRepository!,
      );

      // Check if mounted before updating the state
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error initializing services: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          // Set an error state here if needed
        });
        // Show error message after build is complete
        Future.microtask(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error initializing: ${e.toString()}')),
          );
        });
      }
    }
  }

  Future<void> _addCountry() async {
    if (mounted) {
      setState(() {
        _isFetchingLocation = true; // Start loading
      });
    }

    try {
      String? isoCode = await SimInfoService.getIsoCode();

      if (isoCode != null && mounted) {
        await _countryVisitsRepository!.saveCountryVisit(isoCode);
        await _locationLogsRepository!.logEntry(status: 'success', countryCode: isoCode);

        // Check if mounted before showing dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Location Retrieved"),
              content: Text("You are currently in: $isoCode"),
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
        await _locationLogsRepository!.logEntry(status: 'error');
      }
    } catch (e) {
      if (_locationLogsRepository != null) {
        await _locationLogsRepository!.logEntry(status: 'error');
      }

      // Use Future.microtask to ensure we're not in build
      if (mounted) {
        Future.microtask(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding country: ${e.toString()}')),
          );
        });
      }
    } finally {
      // Only update state if mounted
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

    // Null check to ensure services are initialized
    if (_countryDataService == null || 
        _countryVisitsRepository == null || 
        _locationLogsRepository == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to initialize services'),
              ElevatedButton(
                onPressed: _initializeServices,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final List<Widget> screens = [
      EntriesScreen(
        countryVisitsRepository: _countryVisitsRepository!,
        locationLogsRepository: _locationLogsRepository!,
        countryDataService: _countryDataService!,
      ),
      LogsScreen(logService: _locationLogsRepository!),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings screen when the button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    database: database,
                    isDarkMode: widget.isDarkMode,
                    useSystemTheme: widget.useSystemTheme,
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: screens),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Entries"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Logs"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isFetchingLocation ? null : _addCountry, // Disable when loading
        tooltip: 'Add Current Location',
        backgroundColor: Theme.of(context).primaryColor,
        child: _isFetchingLocation
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add_location),
      ),
    );
  }
}