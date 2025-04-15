import 'package:get_it/get_it.dart';
import 'package:trackie/application/services/export_import_service.dart';
import 'package:trackie/application/services/permission_service.dart';
import 'package:trackie/application/services/file_service.dart';
import 'package:trackie/application/services/location_service.dart';
import 'package:trackie/core/services/notification_service.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/data/repositories/log_country_relations_repository.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/manual_add/manual_add_cubit.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_cubit.dart';
import 'package:trackie/presentation/bloc/theme/theme_cubit.dart';
import 'package:trackie/presentation/bloc/calendar/calendar_cubit.dart';
import 'package:trackie/presentation/bloc/travel_history/travel_history_cubit.dart';
import 'package:trackie/presentation/bloc/current_location/current_location_cubit.dart';

/// Service locator instance
final getIt = GetIt.instance;

/// Dependency injection module
class DependencyInjection {
  static Future<void> init() async {
    try {
      // Database
      getIt.registerSingleton<AppDatabase>(AppDatabase());

      // Themes
      getIt.registerSingleton<ThemeCubit>(ThemeCubit());

      // Services
      getIt.registerSingleton<PermissionService>(PermissionService());
      getIt.registerSingleton<FileService>(FileService());

      // Register NotificationService as a singleton
      getIt.registerLazySingleton<NotificationService>(
          () => NotificationService());

      // Repositories
      getIt.registerFactory<LocationLogsRepository>(
        () => LocationLogsRepository(getIt<AppDatabase>()),
      );
      getIt.registerFactory<CountryVisitsRepository>(
        () => CountryVisitsRepository(getIt<AppDatabase>()),
      );
      getIt.registerFactory<LogCountryRelationsRepository>(
        () => LogCountryRelationsRepository(getIt<AppDatabase>()),
      );

      // Services that use repositories
      getIt.registerFactory<LocationService>(
        () => LocationService(
          locationLogsRepository: getIt<LocationLogsRepository>(),
          countryVisitsRepository: getIt<CountryVisitsRepository>(),
        ),
      );

      // Blocs
      getIt.registerLazySingleton<LocationLogsCubit>(
        () => LocationLogsCubit(getIt<LocationLogsRepository>()),
      );
      getIt.registerLazySingleton<CountryVisitsCubit>(
        () => CountryVisitsCubit(
          getIt<CountryVisitsRepository>(),
          getIt<LocationService>(),
        ),
      );
      getIt.registerLazySingleton<RelationLogsCubit>(
        () => RelationLogsCubit(getIt<LocationLogsRepository>()),
      );
      getIt.registerLazySingleton<CalendarCubit>(
        () => CalendarCubit(locationService: getIt<LocationService>()),
      );
      getIt.registerLazySingleton<TravelHistoryCubit>(
        () => TravelHistoryCubit(getIt<LocationService>()),
      );

      // Register ManualAddCubit
      getIt.registerFactory<ManualAddCubit>(
        () => ManualAddCubit(
          locationService: getIt<LocationService>(),
        ),
      );

      // Export/Import Service
      getIt.registerFactory<DataExportImportService>(
        () => DataExportImportService(
          database: getIt<AppDatabase>(),
          locationLogsRepository: getIt<LocationLogsRepository>(),
          countryVisitsRepository: getIt<CountryVisitsRepository>(),
          logCountryRelationsRepository: getIt<LogCountryRelationsRepository>(),
          locationService: getIt<LocationService>(),
          relationLogsCubit: getIt<RelationLogsCubit>(),
          permissionService: getIt<PermissionService>(),
          fileService: getIt<FileService>(),
        ),
      );

      // Register the CurrentLocationCubit as a singleton
      getIt.registerSingleton<CurrentLocationCubit>(CurrentLocationCubit());
    } catch (e) {
      throw Exception('Failed to initialize dependencies: $e');
    }
  }
}
