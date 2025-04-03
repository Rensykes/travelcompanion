import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';
import 'package:trackie/presentation/providers/preferences_provider.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showErrorLogsAsync = ref.watch(showErrorLogsProvider);
    final logsStream = ref.watch(allLogsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Logs'),
        actions: [
          // Toggle for showing error logs
          showErrorLogsAsync.when(
            data: (showErrorLogs) => Switch(
              value: showErrorLogs,
              onChanged: (value) => ref.read(showErrorLogsProvider.notifier).set(value),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Icon(Icons.error),
          ),
          // Add a refresh button to manually refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allLogsProvider),
          ),
        ],
      ),
      body: showErrorLogsAsync.when(
        data: (showErrorLogs) {
          return logsStream.when(
            data: (logs) {
              // Apply filter based on user preference
              final filteredLogs = showErrorLogs 
                  ? logs 
                  : logs.where((log) => log.status != "error").toList();

              if (filteredLogs.isEmpty) {
                return const Center(child: Text("No logs available"));
              }

              // Display logs
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
                      await ref.read(locationLogsRepositoryProvider).deleteLog(log.id);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Log deleted")),
                        );
                      }
                    },
                    child: ListTile(
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
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading logs: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Failed to load preferences")),
      ),
    );
  }
}