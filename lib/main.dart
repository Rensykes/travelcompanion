import 'package:flutter/material.dart';
import 'services/location_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db/country_adapter.dart';
import 'services/country_service.dart';
import 'widgets/country_chart.dart'; 
import 'widgets/country_calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(CountryVisitAdapter());
  await Hive.openBox<CountryVisit>('country_visits');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Box<CountryVisit> box;

  @override
  void initState() {
    super.initState();
    box = Hive.box<CountryVisit>('country_visits');
  }

  Future<void> _addCountry() async {
    String? country = await LocationService.getCurrentCountry();
    if (country != null) {
      await CountryService.saveCountryVisit(country);
      print('✅ Saved country: $country');
      setState(() {}); // Refresh UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Location Tracker')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _addCountry,
                child: const Text("Get Country"),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<CountryVisit> box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text("No data yet"));
                  }
                  return Column(
                    children: [
                      Expanded(child: CountryChart(box: box)),  // 📊 Chart
                      Expanded(child: SingleChildScrollView(child: CountryCalendar(box: box))), // 📅 Calendar (Fixed)
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
