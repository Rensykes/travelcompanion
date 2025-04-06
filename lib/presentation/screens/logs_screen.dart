import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/presentation/controllers/logs_screen_controller.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';
import 'package:trackie/presentation/providers/preferences_provider.dart';
import 'package:trackie/presentation/widgets/log_entry_tile.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the show error logs preference
    final showErrorLogsAsync = ref.watch(showErrorLogsProvider);

    // Watch the stream of logs from the database
    final logsStreamAsync = ref.watch(allLogsProvider);

    // Access the controller for specific actions
    final controller = ref.read(logsScreenControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Logs'),
        actions: [
          // Show error logs toggle switch
          showErrorLogsAsync.when(
            data:
                (showErrorLogs) => Switch(
                  value: showErrorLogs,
                  onChanged: (value) => controller.toggleErrorLogs(value),
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
      body: logsStreamAsync.when(
        data: (logs) {
          return showErrorLogsAsync.when(
            data: (showErrorLogs) {
              // Apply filter based on user preference
              final filteredLogs =
                  showErrorLogs
                      ? logs
                      : logs.where((log) => log.status != "error").toList();

              if (filteredLogs.isEmpty) {
                return const Center(child: Text("No logs available"));
              }

              return ListView.builder(
                itemCount: filteredLogs.length,
                itemBuilder: (context, index) {
                  final log = filteredLogs[index];

                  return Dismissible(
                    key: Key(log.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      await controller.deleteLog(
                        log.id,
                        (title, message, status) => SnackBarHelper.showSnackBar(
                          context,
                          title,
                          message,
                          status,
                        ),
                        context,
                      );
                    },
                    child: LogEntryTile(log: log),
                  );
                },
              );
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
