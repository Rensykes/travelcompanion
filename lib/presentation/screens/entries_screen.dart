import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:country_flags/country_flags.dart';
import 'package:trackie/repositories/country_data_service_provider.dart';
import 'package:trackie/repositories/country_visits.dart';
import 'relations_screen.dart';

class EntriesScreen extends ConsumerWidget {
  const EntriesScreen({super.key});

  // Show confirmation dialog before deleting
  Future<bool> _showDeleteConfirmation(BuildContext context, WidgetRef ref, CountryVisit visit) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete all data for ${visit.countryCode}? '
          'This will remove all location logs related to this country.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (result == true) {
      try {
        // Use the service through Riverpod
        await ref.read(countryDataServiceProvider).deleteCountryData(visit.countryCode);
        
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Deleted all data for ${visit.countryCode}')),
          );
        }
        return true;
      } catch (e) {
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error deleting data: $e')),
          );
        }
        return false;
      }
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsStream = ref.watch(allVisitsProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Country Visits')),
      body: visitsStream.when(
        data: (visits) {
          if (visits.isEmpty) {
            return const Center(child: Text('No country visits recorded'));
          }
          
          return ListView.builder(
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              return Dismissible(
                key: Key(visit.countryCode),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) => _showDeleteConfirmation(context, ref, visit),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RelationsScreen(
                          countryVisit: visit,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}