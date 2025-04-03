import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/providers/relation_logs_provider.dart';

class RelationsScreen extends ConsumerWidget {
  final CountryVisit countryVisit;
  
  const RelationsScreen({
    super.key,
    required this.countryVisit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(relationLogsProvider(countryVisit.countryCode));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs for ${countryVisit.countryCode}'),
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No logs found for this country'));
          }
          
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                leading: log.status == "success"
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.error, color: Colors.red),
                title: Text("Log #${log.id}"),
                subtitle: Text("Time: ${log.logDateTime}"),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}