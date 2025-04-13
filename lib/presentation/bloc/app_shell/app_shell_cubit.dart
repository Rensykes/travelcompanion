// ignore_for_file: unused_local_variable

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/presentation/bloc/app_shell/app_shell_state.dart';
import 'package:trackie/core/constants/route_constants.dart';

class AppShellCubit extends Cubit<AppShellState> {
  AppShellCubit() : super(const AppShellState());

  bool shouldShowFloatingActionButton(String currentPath) {
    // Check screen paths by name
    final bool isSettingsScreen =
        currentPath.startsWith(RouteConstants.settings);
    final bool isAddScreen = currentPath.startsWith(RouteConstants.add);
    final bool isTravelHistoryScreen =
        currentPath.startsWith(RouteConstants.travelHistory);

    // Show FAB only on Dashboard and Countries screens
    final bool isDashboardScreen =
        currentPath.startsWith(RouteConstants.dashboard);
    final bool isCountriesScreen =
        currentPath.startsWith(RouteConstants.countries);

    return isDashboardScreen || isCountriesScreen;
  }
}
