import 'package:flutter/material.dart';
import '../services/log_service.dart';
import '../database/database.dart';

class LogsScreen extends StatefulWidget {
  final LogService logService;

  const LogsScreen({super.key, required this.logService});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  late Stream<List<LocationLog>> _logsStream;

  @override
  void initState() {
    super.initState();
    // Use the stream instead of ValueListenable
    _logsStream = widget.logService.watchAllLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Logs')),
      body: StreamBuilder<List<LocationLog>>(
        stream: _logsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading logs: ${snapshot.error}'));
          }

          final logs = snapshot.data ?? [];
          
          if (logs.isEmpty) {
            return const Center(child: Text("No logs available"));
          }

          // Display logs in reverse order (newest first)
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              // Get logs in reverse order
              final log = logs[logs.length - 1 - index];
              return ListTile(
                leading: log.status == "success"
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.error, color: Colors.red),
                title: Text(log.status == "success"
                    ? "Country: ${log.countryCode ?? 'Unknown'}"
                    : "Failed to fetch country"),
                subtitle: Text("Time: ${log.logDateTime}"),
              );
            },
          );
        },
      ),
    );
  }
}