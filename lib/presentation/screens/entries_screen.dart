import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:country_flags/country_flags.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_state.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:trackie/core/di/injection_container.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshData();
  }

  void refreshData() {
    context.read<CountryVisitsCubit>().refresh();
  }

  // Show confirmation dialog before deleting
  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    CountryVisit visit,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
        // Delete country data
        final repository = getIt<CountryVisitsRepository>();
        await repository.deleteCountryVisit(visit.countryCode);

        if (context.mounted) {
          SnackBarHelper.showSnackBar(
            context,
            "Deleted",
            'Deleted all data for ${visit.countryCode} 👌',
            ContentType.success,
          );
        }
        // Refresh both cubits after deletion
        if (context.mounted) {
          context.read<CountryVisitsCubit>().refresh();
          context.read<LocationLogsCubit>().refresh();
        }
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
    super.build(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Country Visits')),
      body: BlocBuilder<CountryVisitsCubit, CountryVisitsState>(
        builder: (context, state) {
          if (state is CountryVisitsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CountryVisitsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is CountryVisitsLoaded) {
            final visits = state.visits;

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
                  confirmDismiss: (direction) =>
                      _showDeleteConfirmation(context, visit),
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
                      context.push('/relations/${visit.countryCode}');
                    },
                  ),
                );
              },
            );
          }

          // Initial state
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
