import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/presentation/providers/database_provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:trackie/presentation/providers/theme_preferences_provider.dart';

part 'settings_screen_controller.g.dart';

@riverpod
class SettingsScreenController extends _$SettingsScreenController {
  @override
  Future<SettingsScreenState> build() async {
    // Get theme preferences from the provider
    final themePrefsAsync = await ref.watch(themePreferencesProvider.future);

    return SettingsScreenState(
      isDarkMode: themePrefsAsync.isDarkMode,
      useSystemTheme: themePrefsAsync.useSystemTheme,
    );
  }

  Future<void> toggleSystemTheme(bool value) async {
    // Update theme preferences using the provider
    await ref
        .read(themePreferencesProvider.notifier)
        .setThemeMode(useSystemTheme: value);

    // Refresh current state
    ref.invalidateSelf();
  }

  Future<void> toggleDarkMode(bool value) async {
    // Update theme preferences using the provider
    await ref
        .read(themePreferencesProvider.notifier)
        .setThemeMode(isDarkMode: value);

    // Refresh current state
    ref.invalidateSelf();
  }

  Future<void> cleanupDatabase(BuildContext context) async {
    try {
      final database = ref.read(appDatabaseProvider);

      // Delete all rows from all tables
      await database.delete(database.countryVisits).go();
      await database.delete(database.locationLogs).go();
      await database.delete(database.logCountryRelations).go();
      log('Database cleaned up successfully');

      // Show success dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Database Cleaned'),
                content: const Text(
                  'All records have been deleted from the database.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      log('Error cleaning up database: $e');
      if (context.mounted) {
        SnackBarHelper.showSnackBar(
          context,
          'Error',
          'Error cleaning database: ${e.toString()}',
          ContentType.failure,
        );
      }
    }
  }
}

class SettingsScreenState {
  final bool isDarkMode;
  final bool useSystemTheme;

  const SettingsScreenState({
    required this.isDarkMode,
    required this.useSystemTheme,
  });

  SettingsScreenState copyWith({bool? isDarkMode, bool? useSystemTheme}) {
    return SettingsScreenState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
    );
  }
}
