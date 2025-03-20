import 'package:flutter/material.dart';
import 'package:trackie/repositories/location_logs.dart';
import '../repositories/country_visits.dart';
import '../database/database.dart';
import 'package:country_flags/country_flags.dart';
import 'relations_screen.dart'; // Import the RelationsScreen

class EntriesScreen extends StatefulWidget {
  final CountryVisitsRepository countryService;
  final LocationLogsRepository locationLogsRepository;

  const EntriesScreen({
    super.key,
    required this.countryService,
    required this.locationLogsRepository,
  });

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  late Stream<List<CountryVisit>> _countriesStream;

  @override
  void initState() {
    super.initState();
    _countriesStream = widget.countryService.watchAllVisits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Country Visits')),
      body: StreamBuilder<List<CountryVisit>>(
        stream: _countriesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No country visits recorded'));
          } else {
            final visits = snapshot.data!;
            return ListView.builder(
              itemCount: visits.length,
              itemBuilder: (context, index) {
                final visit = visits[index];
                return ListTile(
                  leading: CountryFlag.fromCountryCode(
                    visit.countryCode,
                    width: 40,
                    height: 30,
                    borderRadius: 8,
                  ),
                  title: Text(visit.countryCode),
                  subtitle: Text('Days: ${visit.daysSpent}'),
                  trailing: Text('Entry: ${_formatDate(visit.entryDate)}'),
                  onTap: () {
                    // Navigate to the RelationsScreen when an item is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RelationsScreen(
                              countryVisit: visit,
                              locationLogsRepository:
                                  widget.locationLogsRepository,
                            ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
