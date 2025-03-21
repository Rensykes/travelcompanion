import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackie/repositories/location_logs.dart';
import 'package:trackie/database/database.dart';

class LogsScreen extends StatefulWidget {
  final LocationLogsRepository logService;

  const LogsScreen({super.key, required this.logService});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> with WidgetsBindingObserver {
  late Stream<List<LocationLog>> _logsStream;
  bool _showErrorLogs = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Add observer to detect when app resumes focus
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize
    _logsStream = widget.logService.watchAllLogs();

    _loadPreferences();
  }

  @override
  void dispose() {
    // Remove observer when widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This will be called when the app resumes or when this screen gets focus
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPreferences();
    }
  }

  // Add this method to refresh settings when returning to this page
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPreferences();
  }

  // Load user preferences for showing error logs
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) { // Check if widget is still mounted
      setState(() {
        _showErrorLogs = prefs.getBool('showErrorLogs') ?? true;
        _isLoading = false;
      });
    }
  }

  // Filter logs based on the user preference
  List<LocationLog> _filterLogs(List<LocationLog> logs) {
    if (_showErrorLogs) {
      return logs; // Return all logs
    } else {
      // Filter out error logs
      return logs.where((log) => log.status != "error").toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Logs'),
        actions: [
          // Add a refresh button to manually refresh preferences
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPreferences,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<LocationLog>>(
              stream: _logsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading logs: ${snapshot.error}'));
                }

                final allLogs = snapshot.data ?? [];
                // Apply filter based on user preference
                final filteredLogs = _filterLogs(allLogs);

                if (filteredLogs.isEmpty) {
                  return const Center(child: Text("No logs available"));
                }

                // Display logs in reverse order (newest first)
                return ListView.builder(
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    // Get logs in reverse order
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
                        // Get the ScaffoldMessenger before the async gap
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        await widget.logService.deleteLog(log.id);

                        // Use the stored reference instead of getting it after the async gap
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
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
            ),
    );
  }
}