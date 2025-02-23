import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db/country_adapter.dart';
import 'services/location_service.dart';
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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3, // 🔹 Three tabs
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Location Tracker'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.list), text: "Entries"),
                Tab(icon: Icon(Icons.pie_chart), text: "Charts"),
                Tab(icon: Icon(Icons.calendar_today), text: "Calendar"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _EntriesTab(box: box),       // 📜 List of Entries
              CountryChart(box: box),      // 📊 Charts
              CountryCalendar(box: box),   // 📅 Calendar
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addCountry,
            child: const Icon(Icons.add_location),
          ),
        ),
      ),
    );
  }
}

// 📜 Tab 1: List of all logged entries
class _EntriesTab extends StatelessWidget {
  final Box<CountryVisit> box;

  const _EntriesTab({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<CountryVisit> box, _) {
        if (box.isEmpty) {
          return const Center(child: Text("No data yet"));
        }
        return ListView.builder(
          itemCount: box.length,
          itemBuilder: (context, index) {
            var visit = box.getAt(index);
            return ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(visit!.countryCode),
              subtitle: Text(
                "Visited on ${visit.entryDate.toLocal().toString().split(' ')[0]} - ${visit.daysSpent} days",
              ),
            );
          },
        );
      },
    );
  }
}
