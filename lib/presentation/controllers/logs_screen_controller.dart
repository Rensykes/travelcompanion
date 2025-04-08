// logs_screen_controller.dart
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';
import 'package:trackie/presentation/providers/preferences_provider.dart';

part 'logs_screen_controller.g.dart';

@riverpod
class LogsScreenController extends _$LogsScreenController {
  @override
  LogsScreenStateData build() {
    return const LogsScreenStateData();
  }

  Future<void> deleteLog(
    int logId,
    Function(String, String, ContentType) showSnackBar,
    BuildContext context,
  ) async {
    try {
      await ref.read(locationLogsRepositoryProvider).deleteLog(logId);
      ref.invalidate(locationLogsProvider);
      if (context.mounted) {
        showSnackBar(
          "Deleted",
          'Log entry successfully removed',
          ContentType.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar("Error", 'Failed to delete log: $e', ContentType.failure);
      }
    }
  }

  Future<void> toggleErrorLogs(bool value) async {
    await ref.read(showErrorLogsProvider.notifier).set(value);
  }
}

class LogsScreenStateData {
  const LogsScreenStateData();

  LogsScreenStateData copyWith() {
    return const LogsScreenStateData();
  }
}
