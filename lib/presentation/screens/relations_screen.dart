import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackie/application/services/location_service.dart';
import 'package:trackie/core/utils/db_util.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_cubit.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_state.dart';
import 'package:trackie/presentation/bloc/notification/notification_bloc.dart';
import 'package:trackie/presentation/bloc/notification/notification_event.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'dart:developer' as developer;
import 'package:trackie/core/utils/data_refresh_util.dart';

class RelationsScreen extends StatefulWidget {
  final CountryVisit countryVisit;

  // TODO: Only need countryCode
  const RelationsScreen({super.key, required this.countryVisit});

  @override
  State<RelationsScreen> createState() => _RelationsScreenState();
}

class _RelationsScreenState extends State<RelationsScreen> {
  late final RelationLogsCubit _relationLogsCubit;
  bool _hasNavigatedBack = false;

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

  void _goBackIfNoLogs() {
    if (!_hasNavigatedBack) {
      _hasNavigatedBack = true;

      // First refresh the data
      DataRefreshUtil.refreshAllData(context: context);

      // Show notification using the NotificationBloc
      context.read<NotificationBloc>().add(
            ShowNotification(
              title: "No Logs",
              message: "No logs found for ${widget.countryVisit.countryCode}",
              type: ContentType.help,
            ),
          );

      // Navigate back safely using GoRouter
      if (context.mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs for ${widget.countryVisit.countryCode}'),
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
              // If no logs are present, refresh data and navigate back safely
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _goBackIfNoLogs();
              });
              return const Center(child: CircularProgressIndicator());
            }

            return _DismissibleLogsList(
              logs: logs,
              countryCode: widget.countryVisit.countryCode,
              onDeleted: () {
                DataRefreshUtil.refreshAllData(context: context);
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

    // If all logs have been dismissed, notify parent
    if (visibleLogs.isEmpty && logs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDeleted();
      });
    }

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
              final repository = getIt<LocationService>();
              if (log.countryCode != null) {
                await repository.deleteLocationLogByIdAndCountryCode(
                    log.id, log.countryCode!);
              } else {
                throw Exception(
                    "Country code cannot be null for log ID: ${log.id}");
              }

              if (context.mounted) {
                // Use the notification bloc instead of direct helper
                context.read<NotificationBloc>().add(
                      ShowNotification(
                        title: "Deleted",
                        message: "Log entry successfully removed",
                        type: ContentType.success,
                      ),
                    );
              }
              return true;
            } catch (e) {
              developer.log("❌ Error dismissing log with ID ${log.id}: $e");
              if (context.mounted) {
                // Use the notification bloc instead of direct helper
                context.read<NotificationBloc>().add(
                      ShowNotification(
                        title: "Error",
                        message: "Failed to delete log: $e",
                        type: ContentType.failure,
                      ),
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
            leading: DBUtils.isValidStatus(log.status)
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
