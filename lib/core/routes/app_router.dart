import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:trackie/core/constants/route_constants.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/bloc/calendar/calendar_cubit.dart';
import 'package:trackie/presentation/screens/advanced_settings_screen.dart';
import 'package:trackie/presentation/screens/app_shell_screen.dart';
import 'package:trackie/presentation/screens/calendar_view_screen.dart';
import 'package:trackie/presentation/screens/entries_screen.dart';
import 'package:trackie/presentation/screens/export_import_screen.dart';
import 'package:trackie/presentation/screens/logs_screen.dart';
import 'package:trackie/presentation/screens/manual_add_screen.dart';
import 'package:trackie/presentation/screens/quick_logs_add_screen.dart';
import 'package:trackie/presentation/screens/relations_screen.dart';
import 'package:trackie/presentation/screens/settings_screen.dart';

final router = GoRouter(
  initialLocation: RouteConstants.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShellScreen(child: child);
      },
      routes: [
        GoRoute(
          path: RouteConstants.home,
          builder: (context, state) => const EntriesScreen(),
          routes: [
            GoRoute(
              path: RouteConstants.relations,
              builder: (context, state) {
                final countryCode =
                    state.pathParameters[RouteConstants.countryCodeParam]!;
                final countryVisit = CountryVisit(
                  countryCode: countryCode,
                  entryDate: DateTime.now(),
                  daysSpent: 0,
                );
                return RelationsScreen(countryVisit: countryVisit);
              },
            ),
          ],
        ),
        GoRoute(
          path: RouteConstants.calendar,
          builder: (context, state) => BlocProvider.value(
            value: GetIt.instance.get<CalendarCubit>(),
            child: const CalendarViewScreen(),
          ),
        ),
        GoRoute(
            path: RouteConstants.logs,
            builder: (context, state) => const LogsScreen()),
        GoRoute(
          path: RouteConstants.add,
          redirect: (context, state) =>
              '${RouteConstants.add}/${RouteConstants.getRouteName(RouteConstants.manualAdd)}',
          routes: [
            GoRoute(
              path: RouteConstants.quickLogsAdd,
              builder: (context, state) => const QuickLogsAddScreen(),
            ),
            GoRoute(
              path: RouteConstants.manualAdd,
              builder: (context, state) => const ManualAddScreen(),
            ),
          ],
        ),
        GoRoute(
          path: RouteConstants.settings,
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: RouteConstants.advancedSettings,
              builder: (context, state) => const AdvancedSettingsScreen(),
            ),
            GoRoute(
              path: RouteConstants.exportImport,
              builder: (context, state) => const ExportImportScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
