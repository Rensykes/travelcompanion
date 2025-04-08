import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/core/app_initialization.dart';
import 'package:trackie/core/utils/app_themes.dart';
import 'package:trackie/presentation/bloc/theme/theme_cubit.dart';
import 'package:trackie/presentation/bloc/theme/theme_state.dart';
import 'package:trackie/core/routes/app_router.dart';
import 'package:trackie/presentation/widgets/app_bloc_provider.dart';


void main() async {
  try {
    await AppInitialization.init();
    runApp(const MyApp());
  } catch (e) {
    // Handle initialization errors
    log(
  'App initialization failed',
  name: 'Main',
  error: e,
  level: 1000, // Optional: indicates a severe error
);

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
