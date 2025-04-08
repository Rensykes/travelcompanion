import 'package:go_router/go_router.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/screens/advanced_settings_screen.dart';
import 'package:trackie/presentation/screens/entries_screen.dart';
import 'package:trackie/presentation/screens/home_screen.dart';
import 'package:trackie/presentation/screens/logs_screen.dart';
import 'package:trackie/presentation/screens/relations_screen.dart';
import 'package:trackie/presentation/screens/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return HomeScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const EntriesScreen(),
          routes: [
            GoRoute(
              path: 'relations/:countryCode',
              builder: (context, state) {
                final countryCode = state.pathParameters['countryCode']!;
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
          path: '/logs',
          builder: (context, state) => const LogsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'advanced',
              builder: (context, state) => const AdvancedSettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
