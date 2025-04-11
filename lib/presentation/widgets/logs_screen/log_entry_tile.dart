// Extract UI components for better organization
import 'package:flutter/material.dart';
import 'package:trackie/data/datasource/database.dart';

class LogEntryTile extends StatelessWidget {
  final LocationLog log;

  const LogEntryTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: log.status == "success" || log.status == "manual_entry"
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.error, color: Colors.red),
      title: Text(
        log.status == "success" || log.status == "manual_entry"
            ? "Country: ${log.countryCode ?? 'Unknown'}"
            : "Failed to fetch country",
      ),
      subtitle: Text("Time: ${log.logDateTime}"),
    );
  }
}
