import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/presentation/providers/country_visits_provider.dart';
import 'package:trackie/presentation/providers/location_logs_provider.dart';
import 'package:trackie/application/services/country_visit_data_service.dart';

part 'country_data_service_provider.g.dart';

@riverpod
CountryDataService countryDataService(Ref ref) {
  final countryVisitsRepository = ref.watch(countryVisitsRepositoryProvider);
  final locationLogsRepository = ref.watch(locationLogsRepositoryProvider);

  return CountryDataService(
    countryVisitsRepository: countryVisitsRepository,
    locationLogsRepository: locationLogsRepository,
  );
}
