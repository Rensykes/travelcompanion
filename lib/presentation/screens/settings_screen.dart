import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/core/di/dependency_injection.dart';
import 'package:trackie/presentation/bloc/theme/theme_cubit.dart';
import 'package:trackie/presentation/bloc/theme/theme_state.dart';
import 'package:trackie/core/constants/route_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _buildSettingsUI(context),
    );
  }

  Widget _buildSettingsUI(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final themeCubit = context.read<ThemeCubit>();
        final useSystemTheme = themeCubit.useSystemTheme;
        final isDarkMode = themeCubit.isDarkMode;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Use System Theme'),
                value: useSystemTheme,
                onChanged: (bool value) {
                  themeCubit.setUseSystemTheme(value);
                },
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: isDarkMode,
                onChanged: useSystemTheme
                    ? null // Disable this switch if using system theme
                    : (bool value) {
                        themeCubit.setDarkMode(value);
                      },
              ),
              const SizedBox(height: 24),
              // Data Management Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Data Management',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              // Export/Import button
              ListTile(
                leading: const Icon(Icons.import_export),
                title: const Text('Export & Import Data'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  context.push(RouteConstants.exportImportFullPath);
                },
              ),
              // Database cleanup button
              ListTile(
                leading: const Icon(Icons.cleaning_services),
                title: const Text('Clean up Database'),
                onTap: () => _cleanupDatabase(context),
              ),
              const SizedBox(height: 24),
              // Advanced settings button
              ListTile(
                title: const Text('Advanced Settings'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  context.push(RouteConstants.advancedSettingsFullPath);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cleanupDatabase(BuildContext context) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear Database'),
          content: const Text(
            'This will delete all data from the database. This action cannot be undone!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear Data'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final database = getIt<AppDatabase>();

        // Delete all rows from all tables
        await database.delete(database.countryVisits).go();
        await database.delete(database.locationLogs).go();
        await database.delete(database.logCountryRelations).go();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Database cleaned up successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cleaning up database: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
