import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_cubit.dart';
import 'package:trackie/presentation/bloc/theme/theme_cubit.dart';

/// Root widget that provides all the necessary repositories and blocs
class AppBlocProvider extends StatelessWidget {
  final Widget child;

  const AppBlocProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AppDatabase(),
        ),
        RepositoryProvider(
          create: (context) => LocationLogsRepository(
            context.read<AppDatabase>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => CountryVisitsRepository(
            context.read<AppDatabase>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LocationLogsCubit(
              context.read<LocationLogsRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => CountryVisitsCubit(
              context.read<CountryVisitsRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => RelationLogsCubit(
              context.read<LocationLogsRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ThemeCubit(),
          ),
        ],
        child: child,
      ),
    );
  }
}
