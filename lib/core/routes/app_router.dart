import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackie/presentation/screens/advanced_settings_screen.dart';
import 'package:trackie/presentation/screens/entries_screen.dart';
import 'package:trackie/presentation/screens/home_screen.dart';
import 'package:trackie/presentation/screens/logs_screen.dart';
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
        ),
        GoRoute(
          path: '/logs',
          builder: (context, state) => const LogsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/settings/advanced',
          builder: (context, state) => const AdvancedSettingsScreen(),
        ),
      ],
    ),
  ],
);
