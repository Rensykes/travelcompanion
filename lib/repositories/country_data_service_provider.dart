import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/repositories/country_visits.dart';
import 'package:trackie/repositories/location_logs.dart';
import 'package:trackie/services/country_visit_data_service.dart';


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