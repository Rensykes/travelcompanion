import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trackie/core/utils/app_themes.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_cubit.dart';
import 'package:trackie/presentation/bloc/theme/theme_cubit.dart';
import 'package:trackie/presentation/bloc/theme/theme_state.dart';
import 'package:trackie/core/routes/app_router.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
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
  getIt.registerSingleton<ThemeCubit>(ThemeCubit());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LocationLogsCubit>()),
        BlocProvider(create: (_) => getIt<CountryVisitsCubit>()),
        BlocProvider(create: (_) => getIt<RelationLogsCubit>()),
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Travel Companion',
            themeMode: themeState.themeMode,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
