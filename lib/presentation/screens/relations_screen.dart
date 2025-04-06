import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';
import 'package:trackie/presentation/providers/relation_logs_provider.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class RelationsScreen extends ConsumerStatefulWidget {
  final CountryVisit countryVisit;

  const RelationsScreen({super.key, required this.countryVisit});

  @override
  ConsumerState<RelationsScreen> createState() => _RelationsScreenState();
}

class _RelationsScreenState extends ConsumerState<RelationsScreen> {
  List<LocationLog> _currentLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      ref.refresh(relationLogsProvider(widget.countryVisit.countryCode));

      final logsAsyncValue = await ref.read(
        relationLogsProvider(widget.countryVisit.countryCode).future,
      );

      if (mounted) {
        setState(() {
          _currentLogs = List.from(logsAsyncValue);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        SnackBarHelper.showSnackBar(
          context,
          "Error",
          'Failed to load logs: ${e.toString()}',
          ContentType.failure,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs for ${widget.countryVisit.countryCode}'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_currentLogs.isEmpty) {
      return const Center(child: Text('No logs found for this country'));
    }

    return ListView.builder(
      itemCount: _currentLogs.length,
      itemBuilder: (context, index) {
        final log = _currentLogs[index];
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
              builder: (BuildContext context) {
                return AlertDialog(
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
                );
              },
            );
          },
          onDismissed: (direction) async {
            final deletedLog = log;
            final deletedIndex = index;

            final newLogs = List<LocationLog>.from(_currentLogs);
            newLogs.removeAt(deletedIndex);

            setState(() {
              _currentLogs = newLogs;
            });

            try {
              final repository = ref.read(locationLogsRepositoryProvider);
              await repository.deleteLog(deletedLog.id);

              if (mounted) {
                SnackBarHelper.showSnackBar(
                  context,
                  "Deleted",
                  'Log entry successfully removed',
                  ContentType.success,
                );

                if (_currentLogs.isEmpty) {
                  Navigator.of(context).pop();
                }
              }
            } catch (e) {
              final restoredLogs = List<LocationLog>.from(_currentLogs);
              if (deletedIndex < restoredLogs.length) {
                restoredLogs.insert(deletedIndex, deletedLog);
              } else {
                restoredLogs.add(deletedLog);
              }

              if (mounted) {
                setState(() {
                  _currentLogs = restoredLogs;
                });

                SnackBarHelper.showSnackBar(
                  context,
                  "Error",
                  'Failed to delete log: ${e is Exception ? e.toString() : "Unknown error"}',
                  ContentType.failure,
                );

                _fetchData(); // already safe
              }
            }
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
