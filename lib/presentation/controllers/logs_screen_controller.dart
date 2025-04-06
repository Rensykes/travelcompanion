// logs_screen_controller.dart
import 'dart:developer';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';
import 'package:trackie/presentation/providers/preferences_provider.dart';

part 'logs_screen_controller.g.dart';

@riverpod
class LogsScreenController extends _$LogsScreenController {
  late final LocationLogsRepository _logsRepository;

  @override
  Future<LogsScreenStateData> build() async {
    _logsRepository = ref.read(locationLogsRepositoryProvider);

    // Initialize state
    final showErrorLogs = await ref.watch(showErrorLogsProvider.future);
    return _fetchLogs(showErrorLogs);
  }

  Future<LogsScreenStateData> _fetchLogs(bool showErrorLogs) async {
    try {
      final logs = await _logsRepository.getAllLogs();
      return LogsScreenStateData(logs: logs, showErrorLogs: showErrorLogs);
    } catch (e) {
      return LogsScreenStateData(
        errorMessage: 'Failed to load logs: $e',
        showErrorLogs: showErrorLogs,
      );
    }
  }

  Future<void> refreshLogs() async {
    state = const AsyncValue.loading();
    final currentState =
        state.valueOrNull ??
        LogsScreenStateData(
          showErrorLogs: await ref.read(showErrorLogsProvider.future),
        );

    try {
      final logs = await _logsRepository.getAllLogs();
      state = AsyncValue.data(
        currentState.copyWith(logs: logs, errorMessage: null),
      );
    } catch (e) {
      state = AsyncValue.error(
        'Failed to refresh logs: $e',
        StackTrace.current,
      );
    }
  }

  Future<void> toggleErrorLogs(bool value) async {
    await ref.read(showErrorLogsProvider.notifier).set(value);

    // We don't need to fetch logs again since the state will rebuild
    // when the showErrorLogsProvider changes
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(showErrorLogs: value));
    }
  }

  Future<void> deleteLog(
    int logId,
    Function(String, String, ContentType) showSnackBar,
    BuildContext context,
  ) async {
    try {
      // Show a loading indicator or disable UI interactions if needed
      await _logsRepository.deleteLog(logId);

      // Update state if successful
      if (state.hasValue) {
        final updatedLogs =
            state.value!.logs.where((log) => log.id != logId).toList();
        state = AsyncValue.data(state.value!.copyWith(logs: updatedLogs));
      }

      // Show success message
      if (context.mounted) {
        showSnackBar(
          "Deleted",
          'Log entry successfully removed',
          ContentType.success,
        );
      }
    } catch (e) {
      // Log the error for debugging
      log('Error deleting log: $e');

      // Show error message to user
      if (context.mounted) {
        showSnackBar(
          "Error",
          'Failed to delete log: ${e is Exception ? e.toString() : "Unknown error"}',
          ContentType.failure,
        );
      }

      // Optionally refresh logs to ensure state is consistent
      await refreshLogs();
    }
  }
}

class LogsScreenStateData {
  final bool isLoading;
  final List<LocationLog>
  logs; // Replace with your actual log model and not database model
  final String? errorMessage;
  final bool showErrorLogs;

  const LogsScreenStateData({
    this.isLoading = false,
    this.logs = const [],
    this.errorMessage,
    this.showErrorLogs = true,
  });

  LogsScreenStateData copyWith({
    bool? isLoading,
    List<LocationLog>? logs,
    String? errorMessage,
    bool? showErrorLogs,
  }) {
    return LogsScreenStateData(
      isLoading: isLoading ?? this.isLoading,
      logs: logs ?? this.logs,
      errorMessage: errorMessage,
      showErrorLogs: showErrorLogs ?? this.showErrorLogs,
    );
  }
}
