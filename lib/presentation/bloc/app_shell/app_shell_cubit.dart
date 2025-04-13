// ignore_for_file: unused_local_variable

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/presentation/bloc/app_shell/app_shell_state.dart';
import 'package:trackie/core/constants/route_constants.dart';

/// Manages the application shell UI state.
///
/// This cubit handles shell-related UI decisions, such as when to show
/// the floating action button based on the current route path.
/// It helps maintain consistent UI behavior across the app's navigation.
class AppShellCubit extends Cubit<AppShellState> {
  /// Creates an AppShellCubit instance with the default state.
  AppShellCubit() : super(const AppShellState());

  /// Determines whether the floating action button should be visible
  /// based on the current route path.
  ///
  /// The FAB is only shown on specific screens where it makes sense
  /// (currently Dashboard and Countries screens).
  ///
  /// Parameters:
  /// - [currentPath]: The current route path in the app
  ///
  /// Returns:
  /// True if the FAB should be shown, false otherwise
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
