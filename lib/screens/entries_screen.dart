import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../db/country_adapter.dart';

// Displays a list of all country visits.
class EntriesScreen extends StatelessWidget {
  final Box<CountryVisit> box;
  const EntriesScreen({super.key, required this.box});

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
