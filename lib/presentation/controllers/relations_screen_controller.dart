// relations_screen_controller.dart
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';
import 'package:trackie/presentation/providers/relation_logs_provider.dart';

part 'relations_screen_controller.g.dart';

@riverpod
class RelationsScreenController extends _$RelationsScreenController {
  @override
  Future<List<LocationLog>> build(String countryCode) async {
    return ref.read(relationLogsProvider(countryCode).future);
  }

  Future<void> deleteLog({
    required int logId,
    required String countryCode,
    required BuildContext context,
    required Function(String, String, ContentType) showSnackBar,
  }) async {
    try {
      await ref.read(locationLogsRepositoryProvider).deleteLog(logId);
      ref.invalidate(relationLogsProvider(countryCode));
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
}

class RelationsScreenStateData {
  const RelationsScreenStateData();

  RelationsScreenStateData copyWith() {
    return const RelationsScreenStateData();
  }
}
