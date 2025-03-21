import 'package:flutter/material.dart';
import 'package:trackie/repositories/location_logs.dart';
import 'package:trackie/repositories/country_visits.dart';
import 'package:trackie/database/database.dart';
import 'package:country_flags/country_flags.dart';
import 'package:trackie/services/country_visit_data_service.dart';
import 'relations_screen.dart';

class EntriesScreen extends StatefulWidget {
  final CountryVisitsRepository countryVisitsRepository;
  final LocationLogsRepository locationLogsRepository;
  final CountryDataService countryDataService; // Add the service

  const EntriesScreen({
    super.key,
    required this.countryVisitsRepository,
    required this.locationLogsRepository,
    required this.countryDataService, // Require the service
  });

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  late Stream<List<CountryVisit>> _countriesStream;

  @override
  void initState() {
    super.initState();
    _countriesStream = widget.countryVisitsRepository.watchAllVisits();
  }

  // Show confirmation dialog before deleting
  Future<bool> _showDeleteConfirmation(BuildContext context, CountryVisit visit) async {
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
        // Use the service instead of local method
        await widget.countryDataService.deleteCountryData(visit.countryCode);
        
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Deleted all data for ${visit.countryCode}')),
          );
        }
        return true;
      } catch (e) {
        if (mounted) {
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
                return Dismissible(
                  key: Key(visit.countryCode),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) => _showDeleteConfirmation(context, visit),
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
                            locationLogsRepository: widget.locationLogsRepository,
                          ),
                        ),
                      );
                    },
                  ),
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