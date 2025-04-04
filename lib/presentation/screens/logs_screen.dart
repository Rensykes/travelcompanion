import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/controllers/logs_screen_controller.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(logsScreenControllerProvider);
    final controller = ref.read(logsScreenControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Logs'),
        actions: [
          stateAsync.when(
            data:
                (state) => Switch(
                  value: state.showErrorLogs,
                  onChanged: (value) => controller.toggleErrorLogs(value),
                ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Icon(Icons.error),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshLogs(),
          ),
        ],
      ),
      body: stateAsync.when(
        data: (state) {
          // Apply filter based on user preference
          final filteredLogs =
              state.showErrorLogs
                  ? state.logs
                  : state.logs.where((log) => log.status != "error").toList();

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
      ),
    );
  }
}

// Extract UI components for better organization
class LogEntryTile extends StatelessWidget {
  final LocationLog log;

  const LogEntryTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          log.status == "success"
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.error, color: Colors.red),
      title: Text(
        log.status == "success"
            ? "Country: ${log.countryCode ?? 'Unknown'}"
            : "Failed to fetch country",
      ),
      subtitle: Text("Time: ${log.logDateTime}"),
    );
  }
}
