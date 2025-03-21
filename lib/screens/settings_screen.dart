
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:trackie/database/database.dart';
import 'package:trackie/screens/advanced_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  final AppDatabase database;
  final bool isDarkMode;
  final bool useSystemTheme;
  final Function(bool isDark, bool useSystemTheme) onThemeChanged;

  const SettingsScreen({
    super.key, 
    required this.database,
    required this.isDarkMode,
    required this.useSystemTheme,
    required this.onThemeChanged,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
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
              onChanged: _useSystemTheme
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
                    builder: (context) => AdvancedSettingsScreen(
                      database: widget.database,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Call the cleanup function when the button is pressed
                await _cleanupDatabase(context);
              },
              child: const Text('Clean up Database'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cleanupDatabase(BuildContext context) async {
    try {
      // Delete all rows from all tables (simplified)
      await widget.database.delete(widget.database.countryVisits).go();
      await widget.database.delete(widget.database.locationLogs).go();
      await widget.database.delete(widget.database.logCountryRelations).go();
      log('Database cleaned up successfully');

      // Check if the widget is still mounted before showing the dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Database Cleaned'),
            content: const Text('All records have been deleted from the database.'),
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