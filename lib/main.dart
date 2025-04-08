import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/core/app_initialization.dart';
import 'package:trackie/core/utils/app_themes.dart';
import 'package:trackie/presentation/bloc/theme/theme_cubit.dart';
import 'package:trackie/presentation/bloc/theme/theme_state.dart';
import 'package:trackie/core/routes/app_router.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_cubit.dart';

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
        BlocProvider(create: (_) => getIt<LocationLogsCubit>()),
        BlocProvider(create: (_) => getIt<CountryVisitsCubit>()),
        BlocProvider(create: (_) => getIt<RelationLogsCubit>()),
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
      ],
      child: child,
    );
  }
}

void main() async {
  try {
    await AppInitialization.init();
    runApp(const MyApp());
  } catch (e) {
    // Handle initialization errors
    debugPrint('App initialization failed: $e');
    // You might want to show an error screen or retry logic here
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBlocProvider(
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
