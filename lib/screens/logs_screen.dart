import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../db/location_log.dart';

class LogsScreen extends StatelessWidget {
  final Box box;

  const LogsScreen({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Logs')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box logBox, _) {
          if (logBox.isEmpty) {
            return const Center(child: Text("No logs available"));
          }

          //TODO list should be in reversed order. Newest on top, Oldest at bottom
          return ListView.builder(
            itemCount: logBox.length,
            itemBuilder: (context, index) {
              final log = logBox.getAt(index) as LocationLog;
              return ListTile(
                leading: log.status == "success"
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.error, color: Colors.red),
                title: Text(log.status == "success"
                    ? "Country: ${log.countryCode}"
                    : "Failed to fetch country"),
                subtitle: Text("Time: ${log.dateTime}"),
              );
            },
          );
        },
      ),
    );
  }
}
