import 'package:flutter/material.dart';
import 'package:trackie/repositories/location_logs.dart';
import 'package:trackie/database/database.dart';

class RelationsScreen extends StatelessWidget {
  final CountryVisit countryVisit;
  final LocationLogsRepository locationLogsRepository;

  const RelationsScreen({
    super.key,
    required this.countryVisit,
    required this.locationLogsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Relations for ${countryVisit.countryCode}')),
      body: FutureBuilder<List<LocationLog>>(
        future: locationLogsRepository.getRelationsForCountryVisit(countryVisit.countryCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No related logs found'));
          } else {
            final logs = snapshot.data!;
            return ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return ListTile(
                  title: Text('Log ID: ${log.id}'),
                  subtitle: Text('Status: ${log.status}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
