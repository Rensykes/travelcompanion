import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';
import 'package:trackie/presentation/providers/preferences_provider.dart';
import 'package:trackie/presentation/widgets/log_entry_tile.dart';
import 'dart:developer' as developer;
import 'package:trackie/data/datasource/database.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  @override
  void initState() {
    super.initState();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(locationLogsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the show error logs preference
    final showErrorLogsAsync = ref.watch(showErrorLogsProvider);

    // Watch the logs from the provider
    final logsAsync = ref.watch(locationLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Logs'),
        actions: [
          // Show error logs toggle switch
          showErrorLogsAsync.when(
            data:
                (showErrorLogs) => Switch(
                  value: showErrorLogs,
                  onChanged: (value) async {
                    await ref.read(showErrorLogsProvider.notifier).set(value);
                  },
                ),
            loading:
                () => const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            error: (_, __) => const Icon(Icons.error),
          ),
        ],
      ),
      body: logsAsync.when(
        data: (logs) {
          return showErrorLogsAsync.when(
            data: (showErrorLogs) {
              // Apply filter based on user preference
              final filteredLogs =
                  showErrorLogs
                      ? List.of(logs)
                      : logs.where((log) => log.status != "error").toList();

              if (filteredLogs.isEmpty) {
                return const Center(child: Text("No logs available"));
              }

              return _DismissibleLogsList(filteredLogs: filteredLogs, ref: ref);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _DismissibleLogsList extends StatefulWidget {
  final List<LocationLog> filteredLogs;
  final WidgetRef ref;

  const _DismissibleLogsList({required this.filteredLogs, required this.ref});

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
              final repository = widget.ref.read(
                locationLogsRepositoryProvider,
              );
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

            // Delay the provider invalidation
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                widget.ref.invalidate(locationLogsProvider);
              }
            });
          },
          child: LogEntryTile(log: log),
        );
      },
    );
  }
}
