import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/controllers/relations_screen_controller.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';

class RelationsScreen extends ConsumerWidget {
  final CountryVisit countryVisit;

  const RelationsScreen({super.key, required this.countryVisit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      relationsScreenControllerProvider(countryVisit.countryCode),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Logs for ${countryVisit.countryCode}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () => ref
                    .read(
                      relationsScreenControllerProvider(
                        countryVisit.countryCode,
                      ).notifier,
                    )
                    .refreshLogs(countryVisit.countryCode),
          ),
        ],
      ),
      body: controller.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (logs) {
          if (logs.isEmpty) {
            // If no logs are present, navigate back to EntriesScreen
            Future.microtask(() => Navigator.of(context).pop());
            return const Center(child: Text('No logs found for this country'));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Dismissible(
                key: ValueKey("log-${log.id}"),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text("Confirm"),
                          content: const Text(
                            "Are you sure you want to delete this log entry?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                  );
                },
                onDismissed: (_) {
                  ref
                      .read(
                        relationsScreenControllerProvider(
                          countryVisit.countryCode,
                        ).notifier,
                      )
                      .deleteLog(
                        logId: log.id,
                        countryCode: countryVisit.countryCode,
                        context: context,
                        showSnackBar: (title, message, contentType) {
                          SnackBarHelper.showSnackBar(
                            context,
                            title,
                            message,
                            contentType,
                          );
                        },
                      );
                },
                child: ListTile(
                  leading:
                      log.status == "success"
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.error, color: Colors.red),
                  title: Text("Log #${log.id}"),
                  subtitle: Text("Time: ${log.logDateTime}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
