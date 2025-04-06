// relations_screen_controller.dart
import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';
import 'package:trackie/presentation/providers/relation_logs_provider.dart';

part 'relations_screen_controller.g.dart';

@riverpod
class RelationsScreenController extends _$RelationsScreenController {
  late final LocationLogsRepository _logsRepository;

  @override
  Future<List<LocationLog>> build(String countryCode) async {
    _logsRepository = ref.read(locationLogsRepositoryProvider);
    return await _fetchLogs(countryCode);
  }

  Future<List<LocationLog>> _fetchLogs(String countryCode) async {
    return await ref.read(relationLogsProvider(countryCode).future);
  }

  Future<void> refreshLogs(String countryCode) async {
    state = const AsyncValue.loading();
    try {
      final logs = await _fetchLogs(countryCode);
      state = AsyncValue.data(logs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteLog({
    required int logId,
    required String countryCode,
    required BuildContext context,
    required Function(String, String, ContentType) showSnackBar,
  }) async {
    try {
      await _logsRepository.deleteLog(logId);
      await refreshLogs(countryCode);

      if (context.mounted) {
        showSnackBar(
          "Deleted",
          'Log entry successfully removed',
          ContentType.success,
        );
      }
    } catch (e) {
      log('Error deleting log: $e');
      if (context.mounted) {
        showSnackBar("Error", 'Failed to delete log: $e', ContentType.failure);
      }
    }
  }
}
