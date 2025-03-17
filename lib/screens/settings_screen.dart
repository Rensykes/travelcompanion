import 'package:flutter/material.dart';
import '../database/database.dart';
import 'dart:developer';

class SettingsScreen extends StatelessWidget {
  final AppDatabase database;

  const SettingsScreen({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                // Call the cleanup function when the button is pressed
                await _cleanupDatabase(context);
              },
              child: const Text('Clean up Database'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cleanupDatabase(BuildContext context) async {
    try {
      // Delete all rows from all tables (simplified)
      await database.delete(database.countryVisits).go();
      await database.delete(database.locationLogs).go();
      await database.delete(database.logCountryRelations).go();
      log('Database cleaned up successfully');

      // Check if the widget is still mounted before showing the dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Database Cleaned'),
            content: const Text('All records have been deleted from the database.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      log('Error cleaning up database: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cleaning database: ${e.toString()}')),
        );
      }
    }
  }
}
