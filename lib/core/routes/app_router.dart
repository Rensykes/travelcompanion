import 'package:go_router/go_router.dart';
import 'package:trackie/core/constants/route_constants.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/screens/advanced_settings_screen.dart';
import 'package:trackie/presentation/screens/entries_screen.dart';
import 'package:trackie/presentation/screens/app_shell_screen.dart';
import 'package:trackie/presentation/screens/logs_screen.dart';
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
          path: RouteConstants.logs,
          builder: (context, state) => const LogsScreen(),
        ),
        GoRoute(
          path: RouteConstants.settings,
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: RouteConstants.advancedSettings,
              builder: (context, state) => const AdvancedSettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
