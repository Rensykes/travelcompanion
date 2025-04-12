// Extract UI components for better organization
import 'package:flutter/material.dart';
import 'package:trackie/core/utils/db_util.dart';
import 'package:trackie/data/datasource/database.dart';

class LogEntryTile extends StatelessWidget {
  final LocationLog log;

  const LogEntryTile({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: DBUtils.isValidStatus(log.status)
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.error, color: Colors.red),
      title: Text(
        DBUtils.isValidStatus(log.status)
            ? "Country: ${log.countryCode ?? 'Unknown'}"
            : "Failed to fetch country",
      ),
      subtitle: Text("Time: ${log.logDateTime}"),
    );
  }
}
