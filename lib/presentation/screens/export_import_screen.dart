import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:trackie/application/services/export_import_service.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'package:trackie/core/utils/data_refresh_util.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';

class ExportImportScreen extends StatefulWidget {
  const ExportImportScreen({super.key});

  @override
  State<ExportImportScreen> createState() => _ExportImportScreenState();
}

class _ExportImportScreenState extends State<ExportImportScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  String _statusMessage = '';
  final DataExportImportService _service = getIt<DataExportImportService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export & Import')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Card(
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Export',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                          'Export your location logs to a JSON file that you can backup or transfer to another device.'),
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isExporting || _isImporting ? null : _exportData,
                icon: const Icon(Icons.upload_file),
                label: const Text('Export Data'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 32),
              const Card(
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Import',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                          'Import location logs from a previously exported JSON file. This will reconstruct your country visits data.'),
                      SizedBox(height: 4),
                      Text(
                        'Note: Importing will not delete your existing data.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isImporting || _isExporting ? null : _importData,
                icon: const Icon(LineIcons.fileDownload),
                label: const Text('Import Data'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: _statusMessage.contains('Error') ||
                              _statusMessage.contains('Failed')
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_isExporting || _isImporting)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: LinearProgressIndicator(),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
      _statusMessage = 'Preparing data for export...';
    });

    try {
      final filePath = await _service.exportData();
      setState(() {
        _statusMessage = 'Data exported successfully to:\n$filePath';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error exporting data: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _importData() async {
    setState(() {
      _isImporting = true;
      _statusMessage = 'Selecting file to import...';
    });

    try {
      final importedCount = await _service.importData();

      // Refresh the UI after successful import
      if (context.mounted) {
        // Refresh data in the app
        DataRefreshUtil.refreshAllData(context: context);
      }

      setState(() {
        _statusMessage =
            'Import completed successfully. $importedCount logs imported.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = e.toString().contains('Import cancelled')
            ? 'Import cancelled'
            : 'Error importing data: $e';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }
}
