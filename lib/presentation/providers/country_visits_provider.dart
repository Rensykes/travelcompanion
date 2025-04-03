import 'dart:developer';
import 'package:drift/drift.dart';
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
Stream<List<CountryVisit>> allVisits(Ref ref) {
  final repository = ref.watch(countryVisitsRepositoryProvider);
  return repository.watchAllVisits();
}