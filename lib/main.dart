import 'package:flutter/material.dart';
import 'services/location_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db/country_adapter.dart';
import 'services/country_service.dart';
import 'widgets/country_chart.dart'; // Import the chart widget

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
      print('Saved country: $country');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Location Tracker')),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: _addCountry,
              child: const Text("Get Country"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<CountryVisit> box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text("No data yet"));
                  }
                  return Column(
                    children: [
                      Expanded(child: CountryChart(box: box)), // 📊 Show Chart
                      Expanded(
                        child: ListView.builder(
                          itemCount: box.length,
                          itemBuilder: (context, index) {
                            final visit = box.getAt(index);
                            return ListTile(
                              title: Text("🇨🇳 ${visit?.countryCode}"),
                              subtitle: Text(
                                "Arrived: ${visit?.entryDate.toLocal()} - ${visit?.daysSpent} days",
                              ),
                            );
                          },
                        ),
                      ),
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
