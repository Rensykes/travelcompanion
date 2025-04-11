import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_cubit.dart';
import 'package:trackie/presentation/bloc/theme/theme_cubit.dart';
import 'package:trackie/presentation/bloc/calendar/calendar_cubit.dart';

/// Root widget that provides all the necessary blocs
class AppBlocProvider extends StatelessWidget {
  final Widget child;

  const AppBlocProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Use the singleton instances from GetIt
        BlocProvider<LocationLogsCubit>.value(
            value: getIt<LocationLogsCubit>()),
        BlocProvider<CountryVisitsCubit>.value(
            value: getIt<CountryVisitsCubit>()),
        BlocProvider<RelationLogsCubit>.value(
            value: getIt<RelationLogsCubit>()),
        BlocProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
        BlocProvider<CalendarCubit>.value(value: getIt<CalendarCubit>()),
        // Don't provide ManualAddCubit here as we want a new instance for each ManualAddScreen
      ],
      child: child,
    );
  }
}
