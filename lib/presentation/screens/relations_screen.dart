import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_cubit.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_state.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'dart:developer' as developer;
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';

class RelationsScreen extends StatefulWidget {
  final CountryVisit countryVisit;

  // TODO: Only need countryCode
  const RelationsScreen({super.key, required this.countryVisit});

  @override
  State<RelationsScreen> createState() => _RelationsScreenState();
}

class _RelationsScreenState extends State<RelationsScreen> {
  late final RelationLogsCubit _relationLogsCubit;

  @override
  void initState() {
    super.initState();
    // Get the cubit from get_it
    _relationLogsCubit = getIt<RelationLogsCubit>();

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _relationLogsCubit.loadLogsForCountry(widget.countryVisit.countryCode);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs for ${widget.countryVisit.countryCode}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _relationLogsCubit.refresh();
            },
          ),
        ],
      ),
      body: BlocBuilder<RelationLogsCubit, RelationLogsState>(
        bloc: _relationLogsCubit,
        builder: (context, state) {
          if (state is RelationLogsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RelationLogsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is RelationLogsLoaded) {
            final logs = state.logs;

            if (logs.isEmpty) {
              // If no logs are present, refresh both cubits and navigate back
              Future.microtask(() {
                context.read<LocationLogsCubit>().refresh();
                context.read<CountryVisitsCubit>().refresh();
                Navigator.of(context).pop();
              });
              return const Center(
                  child: Text('No logs found for this country'));
            }

            return _DismissibleLogsList(
              logs: logs,
              countryCode: widget.countryVisit.countryCode,
              onDeleted: () {
                _relationLogsCubit.refresh();
                context.read<LocationLogsCubit>().refresh();
                context.read<CountryVisitsCubit>().refresh();
              },
            );
          }

          // Initial state
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _DismissibleLogsList extends StatefulWidget {
  final List<LocationLog> logs;
  final String countryCode;
  final VoidCallback onDeleted;

  const _DismissibleLogsList({
    required this.logs,
    required this.countryCode,
    required this.onDeleted,
  });

  @override
  State<_DismissibleLogsList> createState() => _DismissibleLogsListState();
}

class _DismissibleLogsListState extends State<_DismissibleLogsList> {
  late List<LocationLog> logs;
  final Set<int> dismissedLogIds = {};

  @override
  void initState() {
    super.initState();
    logs = List.from(widget.logs);
  }

  @override
  void didUpdateWidget(_DismissibleLogsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs != oldWidget.logs) {
      logs = List.from(widget.logs);
      dismissedLogIds.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out dismissed logs
    final visibleLogs =
        logs.where((log) => !dismissedLogIds.contains(log.id)).toList();

    return ListView.builder(
      itemCount: visibleLogs.length,
      itemBuilder: (context, index) {
        final log = visibleLogs[index];

        return Dismissible(
          key: ValueKey<int>(log.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            try {
              developer.log(
                "🗑️ Confirming dismissal of log with ID: ${log.id}",
              );
              final repository = getIt<LocationLogsRepository>();
              await repository.deleteLog(log.id);

              if (context.mounted) {
                SnackBarHelper.showSnackBar(
                  context,
                  "Deleted",
                  'Log entry successfully removed',
                  ContentType.success,
                );
              }
              return true;
            } catch (e) {
              developer.log("❌ Error dismissing log with ID ${log.id}: $e");
              if (context.mounted) {
                SnackBarHelper.showSnackBar(
                  context,
                  "Error",
                  'Failed to delete log: $e',
                  ContentType.failure,
                );
              }
              return false;
            }
          },
          onDismissed: (direction) {
            // Mark the log as dismissed
            setState(() {
              dismissedLogIds.add(log.id);
            });

            // Notify parent to refresh the data
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                widget.onDeleted();
              }
            });
          },
          child: ListTile(
            leading: log.status == "success" || log.status == "manual_entry"
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.error, color: Colors.red),
            title: Text("Log #${log.id}"),
            subtitle: Text("Time: ${log.logDateTime}"),
          ),
        );
      },
    );
  }
}
