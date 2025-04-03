import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackie/presentation/providers/database_provider.dart';
import 'dart:developer';
import 'package:trackie/presentation/screens/advanced_settings_screen.dart';

// Change to ConsumerStatefulWidget
class SettingsScreen extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final bool useSystemTheme;
  final Function(bool isDark, bool useSystemTheme) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.useSystemTheme,
    required this.onThemeChanged,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

// Now extends ConsumerState directly
class SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool _isDarkMode;
  late bool _useSystemTheme;

  @override
  void initState() {
    super.initState();
    // Initialize with values passed from parent
    _isDarkMode = widget.isDarkMode;
    _useSystemTheme = widget.useSystemTheme;
  }

  // Save theme settings to SharedPreferences
  void _saveThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('useSystemTheme', _useSystemTheme);
    prefs.setBool('darkMode', _isDarkMode);
  }

  // Handle system theme toggle
  void _toggleSystemTheme(bool value) {
    setState(() {
      _useSystemTheme = value;
      if (value) {
        _isDarkMode = false; // Reset dark mode if using system theme
      }
    });
    _saveThemeSettings();
    widget.onThemeChanged(_isDarkMode, _useSystemTheme);
  }

  // Handle dark mode toggle
  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _saveThemeSettings();
    widget.onThemeChanged(_isDarkMode, _useSystemTheme);
  }

  @override
  Widget build(BuildContext context) {
    // Access the database using Riverpod ref
    final database = ref.watch(appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Use System Theme'),
              value: _useSystemTheme,
              onChanged: (bool value) => _toggleSystemTheme(value),
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _isDarkMode,
              onChanged:
                  _useSystemTheme
                      ? null // Disable this switch if using system theme
                      : (bool value) => _toggleDarkMode(value),
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
              onPressed: () async {
                // Pass the database from Riverpod to the cleanup function
                await _cleanupDatabase(context, database);
              },
              child: const Text('Clean up Database'),
            ),
          ],
        ),
      ),
    );
  }

  // Updated to accept database as parameter instead of using widget.database
  Future<void> _cleanupDatabase(BuildContext context, dynamic database) async {
    try {
      // Delete all rows from all tables using the passed database
      await database.delete(database.countryVisits).go();
      await database.delete(database.locationLogs).go();
      await database.delete(database.logCountryRelations).go();
      log('Database cleaned up successfully');

      // Check if the widget is still mounted before showing the dialog
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cleaning database: ${e.toString()}')),
        );
      }
    }
  }
}
