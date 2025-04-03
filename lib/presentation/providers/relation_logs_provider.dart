import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';

// Generate the .g.dart file with: flutter pub run build_runner build
part 'relation_logs_provider.g.dart';

@riverpod
Future<List<LocationLog>> relationLogs(
  Ref ref,
  String countryCode,
) {
  final repository = ref.watch(locationLogsRepositoryProvider);
  return repository.getRelationsForCountryVisit(countryCode);
}