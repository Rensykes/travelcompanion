import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';
import 'package:trackie/presentation/providers/relation_logs_provider.dart';
import 'dart:developer' as developer;

class RelationsScreen extends ConsumerStatefulWidget {
  final CountryVisit countryVisit;

  const RelationsScreen({super.key, required this.countryVisit});

  @override
  ConsumerState<RelationsScreen> createState() => _RelationsScreenState();
}

class _RelationsScreenState extends ConsumerState<RelationsScreen> {
  @override
  void initState() {
    super.initState();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(relationLogsProvider(widget.countryVisit.countryCode));
    });
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(
      relationLogsProvider(widget.countryVisit.countryCode),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Logs for ${widget.countryVisit.countryCode}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(
                relationLogsProvider(widget.countryVisit.countryCode),
              );
            },
          ),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (logs) {
          if (logs.isEmpty) {
            // If no logs are present, navigate back to EntriesScreen
            Future.microtask(() => Navigator.of(context).pop());
            return const Center(child: Text('No logs found for this country'));
          }

          return _DismissibleLogsList(
            logs: logs,
            ref: ref,
            countryCode: widget.countryVisit.countryCode,
          );
        },
      ),
    );
  }
}

class _DismissibleLogsList extends StatefulWidget {
  final List<LocationLog> logs;
  final WidgetRef ref;
  final String countryCode;

  const _DismissibleLogsList({
    required this.logs,
    required this.ref,
    required this.countryCode,
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
                widget.ref.invalidate(relationLogsProvider(widget.countryCode));
              }
            });
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
  }
}
