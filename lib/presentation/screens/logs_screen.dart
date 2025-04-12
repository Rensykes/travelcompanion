import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/application/services/location_service.dart';
import 'package:trackie/core/utils/db_util.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_state.dart';
import 'package:trackie/presentation/widgets/logs_screen/log_entry_tile.dart';
import 'dart:developer' as developer;
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/core/di/dependency_injection.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool _showErrorLogs = true;

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
    context.read<LocationLogsCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Logs'),
        actions: [
          // Show error logs toggle switch
          Switch(
            value: _showErrorLogs,
            onChanged: (value) {
              setState(() {
                _showErrorLogs = value;
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<LocationLogsCubit, LocationLogsState>(
        builder: (context, state) {
          if (state is LocationLogsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LocationLogsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is LocationLogsLoaded) {
            // Apply filter based on user preference
            final filteredLogs = _showErrorLogs
                ? List.of(state.logs)
                : state.logs.where((log) => log.status != DBUtils.failedEntry).toList();

            if (filteredLogs.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  refreshData();
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 100),
                    Center(child: Text("No logs available")),
                  ],
                ),
              );
            }

            return _DismissibleLogsList(
              filteredLogs: filteredLogs,
              onRefresh: refreshData,
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
  final List<LocationLog> filteredLogs;
  final VoidCallback onRefresh;

  const _DismissibleLogsList({
    required this.filteredLogs,
    required this.onRefresh,
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
    logs = List.from(widget.filteredLogs);
  }

  @override
  void didUpdateWidget(_DismissibleLogsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filteredLogs != oldWidget.filteredLogs) {
      logs = List.from(widget.filteredLogs);
      dismissedLogIds.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter out dismissed logs
    final visibleLogs =
        logs.where((log) => !dismissedLogIds.contains(log.id)).toList();

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
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

              // Refresh logs after deletion
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  widget.onRefresh();
                }
              });
            },
            child: LogEntryTile(log: log),
          );
        },
      ),
    );
  }
}
