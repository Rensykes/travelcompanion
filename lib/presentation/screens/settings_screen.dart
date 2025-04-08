import 'package:flutter/material.dart';
import 'package:trackie/presentation/screens/advanced_settings_screen.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/core/di/injection_container.dart';

class SettingsScreenState {
  final bool isDarkMode;
  final bool useSystemTheme;

  SettingsScreenState({
    required this.isDarkMode,
    required this.useSystemTheme,
  });
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Default settings state
  SettingsScreenState settings = SettingsScreenState(
    isDarkMode: false,
    useSystemTheme: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _buildSettingsUI(context),
    );
  }

  Widget _buildSettingsUI(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Use System Theme'),
            value: settings.useSystemTheme,
            onChanged: (bool value) {
              setState(() {
                settings = SettingsScreenState(
                  isDarkMode: settings.isDarkMode,
                  useSystemTheme: value,
                );
              });
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: settings.useSystemTheme
                ? null // Disable this switch if using system theme
                : (bool value) {
                    setState(() {
                      settings = SettingsScreenState(
                        isDarkMode: value,
                        useSystemTheme: settings.useSystemTheme,
                      );
                    });
                  },
          ),
          const SizedBox(height: 24),
          // Advanced settings button
          ListTile(
            title: const Text('Advanced Settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _cleanupDatabase(context),
            child: const Text('Clean up Database'),
          ),
        ],
      ),
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
