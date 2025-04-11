import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';

class DataExportImportService {
  final AppDatabase database;
  final LocationLogsRepository locationLogsRepository;

  DataExportImportService({
    required this.database,
    required this.locationLogsRepository,
  });

  /// Export location logs to a JSON file
  Future<String> exportData() async {
    log(
      "📤 Starting data export process",
      name: 'DataExportImportService',
      level: 0, // INFO
      time: DateTime.now(),
    );

    // Request appropriate storage permissions based on Android version
    bool hasPermission = false;

    // Check and request permissions
    if (Platform.isAndroid) {
      // Different permission strategy based on Android version
      final sdkVersion =
          int.tryParse(Platform.operatingSystemVersion.split(' ').last) ?? 0;

      if (sdkVersion >= 33) {
        // Android 13+: For text/JSON files, we can use photos permission
        final photos = await Permission.photos.request();
        log("Photos permission status: ${photos.name}",
            name: 'DataExportImportService');
        hasPermission = photos.isGranted;
      } else {
        // Android 12 and below: Use regular storage permission
        final storage = await Permission.storage.request();
        log("Storage permission status: ${storage.name}",
            name: 'DataExportImportService');
        hasPermission = storage.isGranted;
      }
    } else {
      // iOS or other platforms may have different requirements
      hasPermission = true;
    }

    if (!hasPermission) {
      log(
        "❌ Storage permissions denied for export",
        name: 'DataExportImportService',
        level: 3, // ERROR
        time: DateTime.now(),
      );
      throw Exception('Storage permissions denied');
    }

    // Get all location logs
    final logs = await locationLogsRepository.getAllLogs();
    log(
      "📊 Retrieved ${logs.length} logs for export",
      name: 'DataExportImportService',
      level: 0, // INFO
      time: DateTime.now(),
    );

    // Convert to a list of maps
    final List<Map<String, dynamic>> logsJson = logs
        .map((log) => {
              'id': log.id,
              'logDateTime': log.logDateTime.toIso8601String(),
              'status': log.status,
              'countryCode': log.countryCode,
            })
        .toList();

    // Convert to JSON
    final jsonData = jsonEncode({'locationLogs': logsJson});

    // Let user select where to save the file
    String? outputDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select where to save your exported data',
    );

    if (outputDir == null) {
      log(
        "⚠️ Export cancelled by user",
        name: 'DataExportImportService',
        level: 2, // WARNING
        time: DateTime.now(),
      );
      throw Exception('Export cancelled');
    }

    // Create file name with timestamp
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final filePath = '$outputDir/trackie_export_$timestamp.json';

    // Write to file
    final file = File(filePath);
    await file.writeAsString(jsonData);

    log(
      "✅ Data successfully exported to: $filePath",
      name: 'DataExportImportService',
      level: 1, // SUCCESS
      time: DateTime.now(),
    );

    return filePath;
  }

  /// Import location logs from a JSON file and rebuild country visits
  Future<int> importData() async {
    log(
      "📥 Starting data import process",
      name: 'DataExportImportService',
      level: 0, // INFO
      time: DateTime.now(),
    );

    // Request appropriate storage permissions based on Android version
    bool hasPermission = false;

    // Check and request permissions
    if (Platform.isAndroid) {
      // Different permission strategy based on Android version
      final sdkVersion =
          int.tryParse(Platform.operatingSystemVersion.split(' ').last) ?? 0;

      if (sdkVersion >= 33) {
        // Android 13+: For text/JSON files, we can use photos permission
        final photos = await Permission.photos.request();
        log("Photos permission status: ${photos.name}",
            name: 'DataExportImportService');
        hasPermission = photos.isGranted;
      } else {
        // Android 12 and below: Use regular storage permission
        final storage = await Permission.storage.request();
        log("Storage permission status: ${storage.name}",
            name: 'DataExportImportService');
        hasPermission = storage.isGranted;
      }
    } else {
      // iOS or other platforms may have different requirements
      hasPermission = true;
    }

    if (!hasPermission) {
      log(
        "❌ Storage permissions denied for import",
        name: 'DataExportImportService',
        level: 3, // ERROR
        time: DateTime.now(),
      );
      throw Exception('Storage permissions denied');
    }

    // Let user select the file to import
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      dialogTitle: 'Select exported data file to import',
    );

    if (result == null || result.files.single.path == null) {
      log(
        "⚠️ Import cancelled by user",
        name: 'DataExportImportService',
        level: 2, // WARNING
        time: DateTime.now(),
      );
      throw Exception('Import cancelled');
    }

    // Read the file
    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    if (!jsonData.containsKey('locationLogs')) {
      log(
        "❌ Invalid file format - missing locationLogs key",
        name: 'DataExportImportService',
        level: 3, // ERROR
        time: DateTime.now(),
      );
      throw Exception(
          'Invalid file format. File does not contain location logs.');
    }

    final locationLogs =
        (jsonData['locationLogs'] as List).cast<Map<String, dynamic>>();
    log(
      "📋 Found ${locationLogs.length} logs to import",
      name: 'DataExportImportService',
      level: 0, // INFO
      time: DateTime.now(),
    );

    // Process the import in a transaction to ensure data consistency
    final importedCount = await database.transaction(() async {
      // Keep track of imported country codes to update country visits
      final Set<String> countryCodes = {};

      // Import each location log
      for (final logData in locationLogs) {
        final locationLog = LocationLogsCompanion.insert(
          logDateTime: DateTime.parse(logData['logDateTime']),
          status: logData['status'],
          countryCode: Value(logData['countryCode']),
        );

        // Insert the log and get its ID
        final insertedLog = await database
            .into(database.locationLogs)
            .insertReturning(locationLog);

        // If the log has a country code, create the relation and track it
        if (logData['countryCode'] != null) {
          final countryCode = logData['countryCode'] as String;

          // Create the log-country relation
          await database.into(database.logCountryRelations).insert(
                LogCountryRelationsCompanion.insert(
                  logId: insertedLog.id,
                  countryCode: countryCode,
                ),
              );

          // Track this country code for later rebuilding of country visits
          countryCodes.add(countryCode);
        }
      }

      log(
        "🔄 Rebuilding country visits for ${countryCodes.length} countries",
        name: 'DataExportImportService',
        level: 0, // INFO
        time: DateTime.now(),
      );

      // Now rebuild the country visits table based on the imported logs
      for (final countryCode in countryCodes) {
        await locationLogsRepository.recalculateDaysSpent(countryCode);
      }

      return locationLogs.length;
    });

    log(
      "✅ Import completed successfully with $importedCount logs imported",
      name: 'DataExportImportService',
      level: 1, // SUCCESS
      time: DateTime.now(),
    );

    return importedCount;
  }
}
