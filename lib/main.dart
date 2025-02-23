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
  int _selectedIndex = 0; // Track current tab index

  @override
  void initState() {
    super.initState();
    box = Hive.box<CountryVisit>('country_visits');
  }

  Future<void> _addCountry() async {
    String? country = await LocationService.getCurrentCountry();
    if (country != null) {
      await CountryService.saveCountryVisit(country);
      setState(() {}); // Refresh UI
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      _EntriesTab(box: box), // 📜 List of Entries
      Padding(               // ✅ Add padding to fix tooltip overlap
        padding: const EdgeInsets.only(top: 30),
        child: CountryChart(box: box),
      ),
      CountryCalendar(box: box), // 📅 Calendar
    ];

    return MaterialApp(
      home: SafeArea( // ✅ Prevents overlap with status bar
        child: Scaffold(
          body: _screens[_selectedIndex], // Show selected tab content
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
            child: const Icon(Icons.add_location),
          ),
        ),
      ),
    );
  }
}

class _EntriesTab extends StatelessWidget {
  final Box<CountryVisit> box;

  const _EntriesTab({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: box.length,
      itemBuilder: (context, index) {
        final visit = box.getAt(index);
        return ListTile(
          leading: const Icon(Icons.place, color: Colors.blue),
          title: Text(visit!.countryCode),
          subtitle: Text("Visited on ${visit.entryDate.toLocal()} for ${visit.daysSpent} days"),
        );
      },
    );
  }
}
