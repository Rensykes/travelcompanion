import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';

// Generate the .g.dart file with: flutter pub run build_runner build
part 'relation_logs_provider.g.dart';

// Provider that returns a stream for reactive updates
@riverpod
Stream<List<LocationLog>> relationLogsStream(Ref ref, String countryCode) {
  final repository = ref.watch(locationLogsRepositoryProvider);
  // We need to create a new method in the repository for watching relations
  return repository.watchRelationsForCountryVisit(countryCode);
}

// Keep the existing provider for compatibility
@riverpod
Future<List<LocationLog>> relationLogs(Ref ref, String countryCode) {
  final repository = ref.watch(locationLogsRepositoryProvider);
  return repository.getRelationsForCountryVisit(countryCode);
}
