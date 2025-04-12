import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:trackie/application/services/location_service.dart';
import 'package:trackie/presentation/widgets/custom_google_navbar.dart';
import 'package:trackie/presentation/widgets/country_add_menu.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/app_shell/app_shell_cubit.dart';
import 'package:trackie/presentation/bloc/app_shell/app_shell_state.dart';
import 'package:trackie/core/constants/route_constants.dart';
import 'package:trackie/core/utils/data_refresh_util.dart';

class AppShellScreen extends StatefulWidget {
  final Widget child;

  const AppShellScreen({
    super.key,
    required this.child,
  });

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen>
    with WidgetsBindingObserver {
  late final AppShellCubit _appShellCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appShellCubit = AppShellCubit(
      locationService: GetIt.instance.get<LocationService>(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appShellCubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes to foreground
      refreshAllData();
    }
  }

  void refreshAllData() {
    DataRefreshUtil.refreshAllData(context: context);
  }

  int _getCurrentIndex(BuildContext context) {
    final location =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    if (location.startsWith(RouteConstants.calendar)) return 1;
    if (location.startsWith(RouteConstants.logs)) return 2;
    if (location.startsWith(RouteConstants.settings)) return 3;
    return 0;
  }

  void _onTabChange(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteConstants.home);
        break;
      case 1:
        context.go(RouteConstants.calendar);
        break;
      case 2:
        context.go(RouteConstants.logs);
        break;
      case 3:
        context.go(RouteConstants.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _appShellCubit,
      child: BlocBuilder<AppShellCubit, AppShellState>(
        builder: (context, homeState) {
          final currentPath =
              GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
          final showFab =
              _appShellCubit.shouldShowFloatingActionButton(currentPath);

          return Scaffold(
            //appBar: AppBar(title: const Text('Trackie')),
            body: SafeArea(
              child: widget.child,
            ),
            bottomNavigationBar: CustomGoogleNavBar(
              selectedIndex: _getCurrentIndex(context),
              onTabChange: (index) => _onTabChange(context, index),
            ),
            floatingActionButton: showFab ? const CountryAddMenu() : null,
          );
        },
      ),
    );
  }
}
