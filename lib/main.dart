import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/core/app_initialization.dart';
import 'package:trackie/core/utils/app_themes.dart';
import 'package:trackie/presentation/bloc/theme/theme_cubit.dart';
import 'package:trackie/presentation/bloc/theme/theme_state.dart';
import 'package:trackie/core/routes/app_router.dart';
import 'package:trackie/presentation/widgets/app_bloc_provider.dart';
import 'package:trackie/presentation/widgets/first_run_handler.dart';
import 'package:trackie/presentation/helpers/notification_helper.dart';

// Create a global navigator key for the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// This flag will be set by the flavor-specific main_*.dart files
bool isDebugMode = false;

void main() async {
  try {
    // Initialize core app dependencies
    await AppInitialization.init(isDebugMode: isDebugMode);

    // Set the navigator key in NotificationHelper
    NotificationHelper.setNavigatorKey(navigatorKey);

    runApp(MyApp(isDebugMode: isDebugMode));
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
  final bool isDebugMode;

  const MyApp({super.key, required this.isDebugMode});

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
            builder: (context, child) {
              return FirstRunHandler(
                child: child ?? const SizedBox(),
                isDebugMode: isDebugMode,
              );
            },
          );
        },
      ),
    );
  }
}
