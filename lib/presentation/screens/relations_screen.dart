import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackie/application/services/location_service.dart';
import 'package:trackie/core/utils/db_util.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_cubit.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_state.dart';
import 'package:trackie/core/constants/route_constants.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'dart:developer' as developer;
import 'package:trackie/core/utils/data_refresh_util.dart';
import 'package:trackie/presentation/helpers/notification_helper.dart';

class RelationsScreen extends StatefulWidget {
  final CountryVisit countryVisit;

  // TODO: Only need countryCode
  const RelationsScreen({super.key, required this.countryVisit});

  @override
  State<RelationsScreen> createState() => _RelationsScreenState();
}

class _RelationsScreenState extends State<RelationsScreen>
    with SingleTickerProviderStateMixin {
  late final RelationLogsCubit _relationLogsCubit;
  bool _isFirstLoad = true;
  bool _hasHandledEmptyState = false;
  bool _showManualBackOption = false;

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

  void _navigateToCountriesScreen() {
    try {
      context.go(RouteConstants.countriesFullPath);
    } catch (e) {
      developer.log("Error navigating to countries: $e");
      // Fall back to direct navigation
      Navigator.of(context).pop();
    }
  }

  void _handleEmptyLogs() {
    if (!_hasHandledEmptyState) {
      _hasHandledEmptyState = true;

      // First refresh the data
      DataRefreshUtil.refreshAllData(context: context);

      // Show notification
      NotificationHelper.showNotification(
        context,
        "No Logs",
        "No logs found for ${widget.countryVisit.countryCode}",
        ContentType.help,
      );

      // Show manual back option after a delay if navigation fails
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showManualBackOption = true;
          });
        }
      });

      // Try to navigate directly to countries screen
      _navigateToCountriesScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs for ${widget.countryVisit.countryCode}'),
        leading: BackButton(
          onPressed: _navigateToCountriesScreen,
        ),
      ),
      body: BlocConsumer<RelationLogsCubit, RelationLogsState>(
        bloc: _relationLogsCubit,
        listenWhen: (previous, current) {
          // Only handle empty logs on first load or when explicitly set
          if (current is RelationLogsLoaded && current.logs.isEmpty) {
            return _isFirstLoad || previous is! RelationLogsLoaded;
          }
          return false;
        },
        listener: (context, state) {
          if (state is RelationLogsLoaded && state.logs.isEmpty) {
            _isFirstLoad = false;
            _handleEmptyLogs();
          }
        },
        builder: (context, state) {
          // Handle the loaded state first to prevent flickering
          if (state is RelationLogsLoaded) {
            _isFirstLoad = false;
            final logs = state.logs;

            if (logs.isEmpty) {
              // Handle empty logs here too for redundancy
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleEmptyLogs();
              });
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text("No logs found for this country"),
                    if (_showManualBackOption) ...[
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _navigateToCountriesScreen,
                        child: const Text("Return to Countries"),
                      ),
                    ],
                  ],
                ),
              );
            }

            return _DismissibleLogsList(
              logs: logs,
              countryCode: widget.countryVisit.countryCode,
              onDeleted: () {
                DataRefreshUtil.refreshAllData(context: context);
                // Reload logs after deletion to check if we need to navigate back
                _relationLogsCubit
                    .loadLogsForCountry(widget.countryVisit.countryCode);
              },
              onAllLogsDeleted: () {
                _handleEmptyLogs();
              },
            );
          } else if (state is RelationLogsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _navigateToCountriesScreen,
                    child: const Text("Return to Countries"),
                  ),
                ],
              ),
            );
          }

          // Loading or initial state
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
  final VoidCallback onAllLogsDeleted;

  const _DismissibleLogsList({
    required this.logs,
    required this.countryCode,
    required this.onDeleted,
    required this.onAllLogsDeleted,
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
        // Also notify that all logs are gone
        widget.onAllLogsDeleted();
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
                // Use direct notification helper instead of bloc
                NotificationHelper.showNotification(
                  context,
                  "Deleted",
                  "Log entry successfully removed",
                  ContentType.success,
                );
              }
              return true;
            } catch (e) {
              developer.log("❌ Error dismissing log with ID ${log.id}: $e");
              if (context.mounted) {
                // Use direct notification helper instead of bloc
                NotificationHelper.showNotification(
                  context,
                  "Error",
                  "Failed to delete log: $e",
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

            // Check if this was the last log
            if (dismissedLogIds.length >= logs.length) {
              // This was the last log, handle navigation
              widget.onAllLogsDeleted();
            } else {
              // Notify parent to refresh the data
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  widget.onDeleted();
                }
              });
            }
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
