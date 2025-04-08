import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/providers/database_provider.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';

part 'country_visits_provider.g.dart';

@riverpod
CountryVisitsRepository countryVisitsRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return CountryVisitsRepository(database);
}

@riverpod
class CountryVisits extends _$CountryVisits {
  @override
  Future<List<CountryVisit>> build() async {
    // Watch the database provider to trigger rebuilds when database changes
    ref.watch(appDatabaseProvider);

    final repository = ref.watch(countryVisitsRepositoryProvider);
    return repository.getAllVisits();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(countryVisitsRepositoryProvider);
      return repository.getAllVisits();
    });
  }
}
