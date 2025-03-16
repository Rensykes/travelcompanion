import 'package:flutter/material.dart';
import '../services/country_service.dart';
import '../database/database.dart';

class EntriesScreen extends StatefulWidget {
  final CountryService countryService;

  const EntriesScreen({super.key, required this.countryService});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  late Stream<List<CountryVisit>> _countriesStream;

  @override
  void initState() {
    super.initState();
    // Use a stream instead of a future for reactive updates
    _countriesStream = widget.countryService.watchAllVisits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Visits'),
      ),
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
                  leading: CircleAvatar(
                    child: Text(visit.countryCode.substring(0, 2)),
                  ),
                  title: Text(visit.countryCode),
                  subtitle: Text('Days: ${visit.daysSpent}'),
                  trailing: Text('Entry: ${_formatDate(visit.entryDate)}'),
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