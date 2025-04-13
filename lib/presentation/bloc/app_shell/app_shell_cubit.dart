import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/presentation/bloc/app_shell/app_shell_state.dart';
import 'package:trackie/core/constants/route_constants.dart';

class AppShellCubit extends Cubit<AppShellState> {
  AppShellCubit() : super(const AppShellState());

  bool shouldShowFloatingActionButton(String currentPath) {
    // Check screen paths by name
    final bool isCalendarScreen =
        currentPath.startsWith(RouteConstants.calendar);
    final bool isSettingsScreen =
        currentPath.startsWith(RouteConstants.settings);
    final bool isAddScreen = currentPath.startsWith(RouteConstants.add);

    // Hide FAB on calendar and settings screens
    return !isCalendarScreen && !isSettingsScreen && !isAddScreen;
  }
}
