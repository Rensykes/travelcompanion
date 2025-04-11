import 'package:get_it/get_it.dart';
import 'package:trackie/application/services/export_import_service.dart';
import 'package:trackie/application/services/permission_service.dart';
import 'package:trackie/application/services/file_service.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_cubit.dart';
import 'package:trackie/presentation/bloc/theme/theme_cubit.dart';
import 'package:trackie/presentation/bloc/calendar/calendar_cubit.dart';

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
      getIt.registerFactory<CalendarCubit>(
        () => CalendarCubit(
            locationLogsRepository: getIt<LocationLogsRepository>()),
      );

      // Export/Import Service
      getIt.registerFactory<DataExportImportService>(
        () => DataExportImportService(
          database: getIt<AppDatabase>(),
          locationLogsRepository: getIt<LocationLogsRepository>(),
          countryVisitsRepository: getIt<CountryVisitsRepository>(),
          relationLogsCubit: getIt<RelationLogsCubit>(),
          permissionService: getIt<PermissionService>(),
          fileService: getIt<FileService>(),
        ),
      );
    } catch (e) {
      throw Exception('Failed to initialize dependencies: $e');
    }
  }
}
