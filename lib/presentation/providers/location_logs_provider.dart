import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/providers/database_provider.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';

part 'location_logs_provider.g.dart';

@riverpod
LocationLogsRepository locationLogsRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return LocationLogsRepository(database);
}

// This provider gives a stream of logs that will automatically update the UI
@riverpod
Stream<List<LocationLog>> allLogs(Ref ref) {
  final repository = ref.watch(locationLogsRepositoryProvider);
  return repository.watchAllLogs();
}

// This provider can be used for one-time fetches rather than reactive updates
@riverpod
Future<List<LocationLog>> filteredLogs(
  Ref ref, {
  required bool showErrorLogs,
}) async {
  final allLogs = await ref.watch(locationLogsRepositoryProvider).getAllLogs();
  if (showErrorLogs) {
    return allLogs;
  } else {
    return allLogs.where((log) => log.status != "error").toList();
  }
}
