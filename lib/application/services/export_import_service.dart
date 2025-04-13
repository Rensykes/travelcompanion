import 'dart:convert';
import 'dart:developer';

import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/log_country_relations_repository.dart';
import 'package:trackie/application/services/location_service.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_cubit.dart';
import 'package:trackie/application/services/permission_service.dart';
import 'package:trackie/application/services/file_service.dart';

/// Service for handling data export and import operations.
///
/// This service provides functionality to:
/// - Export all location logs to a JSON file
/// - Import location logs from a previously exported JSON file
/// - Rebuild country visits based on imported logs
///
/// It coordinates between multiple repositories and services to ensure
/// data consistency during export and import operations, and handles
/// permissions, file access, and data transformation.
class DataExportImportService {
  /// Direct access to the application database
  final AppDatabase database;

  /// Repository for location log operations
  final LocationLogsRepository locationLogsRepository;

  /// Repository for country visit operations
  final CountryVisitsRepository countryVisitsRepository;

  /// Repository for log-country relation operations
  final LogCountryRelationsRepository logCountryRelationsRepository;

  /// Service for high-level location operations
  final LocationService locationService;

  /// Cubit for managing relation logs state
  final RelationLogsCubit relationLogsCubit;

  /// Service for handling permissions
  final PermissionService _permissionService;

  /// Service for file operations
  final FileService _fileService;

  /// Creates a DataExportImportService with all required dependencies.
  ///
  /// Parameters:
  /// - [database]: The application's database instance
  /// - [locationLogsRepository]: Repository for location logs
  /// - [countryVisitsRepository]: Repository for country visits
  /// - [logCountryRelationsRepository]: Repository for relations
  /// - [locationService]: Service for location operations
  /// - [relationLogsCubit]: Cubit for relation logs state
  /// - [permissionService]: Service for permission handling
  /// - [fileService]: Service for file operations
  DataExportImportService({
    required this.database,
    required this.locationLogsRepository,
    required this.countryVisitsRepository,
    required this.logCountryRelationsRepository,
    required this.locationService,
    required this.relationLogsCubit,
    required PermissionService permissionService,
    required FileService fileService,
  })  : _permissionService = permissionService,
        _fileService = fileService;

  /// Exports all location logs to a JSON file.
  ///
  /// This method:
  /// 1. Requests storage permissions
  /// 2. Retrieves all location logs
  /// 3. Transforms logs to JSON format
  /// 4. Lets the user pick a directory to save the file
  /// 5. Writes the JSON data to a timestamped file
  ///
  /// Returns:
  /// The path to the exported file
  ///
  /// Throws:
  /// - Exception if storage permissions are denied
  /// - Exception if the user cancels the export
  Future<String> exportData() async {
    log("📤 Starting data export process", name: 'DataExportImportService');

    if (!await _permissionService.requestStoragePermission()) {
      log("❌ Storage permissions denied for export",
          name: 'DataExportImportService', level: 3);
      throw Exception('Storage permissions denied');
    }

    final logs = await locationLogsRepository.getAllLogs();
    log("📊 Retrieved ${logs.length} logs for export",
        name: 'DataExportImportService');

    final logsJson = logs
        .map((log) => {
              'id': log.id,
              'logDateTime': log.logDateTime.toIso8601String(),
              'status': log.status,
              'countryCode': log.countryCode,
            })
        .toList();

    final jsonData = jsonEncode({'locationLogs': logsJson});

    final outputDir = await _fileService.pickDirectory(
      dialogTitle: 'Select where to save your exported data',
    );

    if (outputDir == null) {
      log("⚠️ Export cancelled by user",
          name: 'DataExportImportService', level: 2);
      throw Exception('Export cancelled');
    }

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final filePath = '$outputDir/trackie_export_$timestamp.json';

    await _fileService.writeToFile(filePath, jsonData);

    log("✅ Data successfully exported to: $filePath",
        name: 'DataExportImportService', level: 1);
    return filePath;
  }

  /// Imports location logs from a JSON file and rebuilds country visits.
  ///
  /// This method:
  /// 1. Requests storage permissions
  /// 2. Lets the user select a JSON file to import
  /// 3. Reads and parses the file contents
  /// 4. Validates the file format
  /// 5. Uses a database transaction to ensure consistency
  /// 6. Adds each log entry and rebuilds country visits
  ///
  /// Returns:
  /// The number of log entries successfully imported
  ///
  /// Throws:
  /// - Exception if storage permissions are denied
  /// - Exception if the user cancels the import
  /// - Exception if the file has an invalid format
  Future<int> importData() async {
    log("📥 Starting data import process", name: 'DataExportImportService');

    if (!await _permissionService.requestStoragePermission()) {
      log("❌ Storage permissions denied for import",
          name: 'DataExportImportService', level: 3);
      throw Exception('Storage permissions denied');
    }

    final filePath = await _fileService.pickFile(
      dialogTitle: 'Select exported data file to import',
      allowedExtensions: ['json'],
    );

    if (filePath == null) {
      log("⚠️ Import cancelled by user",
          name: 'DataExportImportService', level: 2);
      throw Exception('Import cancelled');
    }

    final jsonString = await _fileService.readFromFile(filePath);
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    if (!jsonData.containsKey('locationLogs')) {
      log("❌ Invalid file format - missing locationLogs key",
          name: 'DataExportImportService', level: 3);
      throw Exception(
          'Invalid file format. File does not contain location logs.');
    }

    final locationLogs =
        (jsonData['locationLogs'] as List).cast<Map<String, dynamic>>();
    log("📋 Found ${locationLogs.length} logs to import",
        name: 'DataExportImportService');

    int importedCount = 0;

    await database.transaction(() async {
      for (final logData in locationLogs) {
        // Create location log
        await locationService.addEntry(
          logDateTime: DateTime.parse(logData['logDateTime']),
          logSource: logData['status'],
          countryCode: logData['countryCode'],
        );
        importedCount++;
      }
      return importedCount;
    });

    log("✅ Import completed successfully with $importedCount logs imported",
        name: 'DataExportImportService', level: 1);
    return importedCount;
  }
}
