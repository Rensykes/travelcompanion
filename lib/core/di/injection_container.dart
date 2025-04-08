import 'package:get_it/get_it.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_cubit.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Database
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  // Repositories
  getIt.registerFactory<LocationLogsRepository>(
    () => LocationLogsRepository(getIt<AppDatabase>()),
  );
  getIt.registerFactory<CountryVisitsRepository>(
    () => CountryVisitsRepository(getIt<AppDatabase>()),
  );

  // Blocs
  getIt.registerFactory<LocationLogsCubit>(
    () => LocationLogsCubit(getIt<LocationLogsRepository>()),
  );
  getIt.registerFactory<CountryVisitsCubit>(
    () => CountryVisitsCubit(getIt<CountryVisitsRepository>()),
  );
  getIt.registerFactory<RelationLogsCubit>(
    () => RelationLogsCubit(getIt<LocationLogsRepository>()),
  );
}
