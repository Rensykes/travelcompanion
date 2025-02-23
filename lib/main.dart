import 'package:flutter/material.dart';
import 'services/location_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db/country_adapter.dart'; // Import your model file
import 'services/country_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();

  // Register the adapter
  Hive.registerAdapter(CountryVisitAdapter());

  await Hive.openBox<CountryVisit>('country_visits');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void printHiveData() async {
    final box = await Hive.openBox<CountryVisit>("country_visits");
    
    print("📦 Hive Data:");
    for (var visit in box.values) {
      print("${visit.countryCode} - ${visit.entryDate} - ${visit.daysSpent} days");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Location Tracker')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              String? country = await LocationService.getCurrentCountry();
              if (country != null) {
                await CountryService.saveCountryVisit(country);
              print('Saved country: $country');
              printHiveData();
              }
            },
            child: Text("Get Country"),
          ),
        ),
      ),
    );
  }
}
