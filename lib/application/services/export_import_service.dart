import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_cubit.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:trackie/application/services/permission_service.dart';
import 'package:trackie/application/services/file_service.dart';

class DataExportImportService {
  final AppDatabase database;
  final LocationLogsRepository locationLogsRepository;
  final CountryVisitsRepository countryVisitsRepository;
  final RelationLogsCubit relationLogsCubit;
  final PermissionService _permissionService;
  final FileService _fileService;

  DataExportImportService({
    required this.database,
    required this.locationLogsRepository,
    required this.countryVisitsRepository,
    required this.relationLogsCubit,
    required PermissionService permissionService,
    required FileService fileService,
  })  : _permissionService = permissionService,
        _fileService = fileService;

  /// Export location logs to a JSON file
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

  /// Import location logs from a JSON file and rebuild country visits
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

    final importedCount = await database.transaction(() async {
      final Set<String> countryCodes = {};

      for (final logData in locationLogs) {
        final locationLog = LocationLogsCompanion.insert(
          logDateTime: DateTime.parse(logData['logDateTime']),
          status: logData['status'],
          countryCode: Value(logData['countryCode']),
        );

        final insertedLog = await database
            .into(database.locationLogs)
            .insertReturning(locationLog);

        if (logData['countryCode'] != null) {
          final countryCode = logData['countryCode'] as String;

          await database.into(database.logCountryRelations).insert(
                LogCountryRelationsCompanion.insert(
                  logId: insertedLog.id,
                  countryCode: countryCode,
                ),
              );

          countryCodes.add(countryCode);
        }
      }

      log("🔄 Rebuilding country visits for ${countryCodes.length} countries",
          name: 'DataExportImportService');

      // Recalculate days spent for each country
      for (final countryCode in countryCodes) {
        await locationLogsRepository.recalculateDaysSpent(countryCode);
      }

      // Recalculate relation logs
      log("🔄 Rebuilding relation logs", name: 'DataExportImportService');
      await relationLogsCubit.refresh();

      return locationLogs.length;
    });

    log("✅ Import completed successfully with $importedCount logs imported",
        name: 'DataExportImportService', level: 1);
    return importedCount;
  }
}
