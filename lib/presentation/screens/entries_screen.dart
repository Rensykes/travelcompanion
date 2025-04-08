import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:country_flags/country_flags.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:trackie/presentation/providers/country_data_service_provider.dart';
import 'package:trackie/presentation/providers/country_visits_provider.dart';
import 'relations_screen.dart';

class EntriesScreen extends ConsumerStatefulWidget {
  const EntriesScreen({super.key});

  @override
  ConsumerState<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends ConsumerState<EntriesScreen> {
  @override
  void initState() {
    super.initState();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(countryVisitsProvider.notifier).refresh();
    });
  }

  // Show confirmation dialog before deleting
  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    CountryVisit visit,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text(
              'Are you sure you want to delete all data for ${visit.countryCode}? '
              'This will remove all location logs related to this country.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (result == true) {
      try {
        // Use the service through Riverpod
        await ref
            .read(countryDataServiceProvider)
            .deleteCountryData(visit.countryCode);

        if (context.mounted) {
          SnackBarHelper.showSnackBar(
            context,
            "Deleted",
            'Deleted all data for ${visit.countryCode} 👌',
            ContentType.success,
          );
        }
        // Refresh the visits after deletion
        ref.read(countryVisitsProvider.notifier).refresh();
        return true;
      } catch (e) {
        if (context.mounted) {
          SnackBarHelper.showSnackBar(
            context,
            "Deleted",
            'Error deleting data: $e ❌',
            ContentType.failure,
          );
        }
        return false;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final visitsAsync = ref.watch(countryVisitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Country Visits')),
      body: visitsAsync.when(
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
                confirmDismiss:
                    (direction) => _showDeleteConfirmation(context, ref, visit),
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
                        builder:
                            (context) => RelationsScreen(countryVisit: visit),
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
