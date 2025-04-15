import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  AdvancedSettingsScreenState createState() => AdvancedSettingsScreenState();
}

class AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  bool _showErrorLogs = true;

  @override
  void initState() {
    super.initState();
    // Load the preference when the screen is initialized
    _loadPreferences();
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showErrorLogs = prefs.getBool('showErrorLogs') ?? true;
    });
    log(
      '🔄 Loaded showErrorLogs preference: $_showErrorLogs',
      name: 'AdvancedSettingsScreen',
      level: 0, // INFO
      time: DateTime.now(),
    );
  }

  // Save the error logs preference
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showErrorLogs', _showErrorLogs);
    log(
      '💾 Saved showErrorLogs preference: $_showErrorLogs',
      name: 'AdvancedSettingsScreen',
      level: 1, // SUCCESS
      time: DateTime.now(),
    );
  }

  // Handle error logs toggle
  void _toggleErrorLogs(bool value) {
    setState(() {
      _showErrorLogs = value;
    });
    _savePreferences();
    log(
      '🔀 Toggled showErrorLogs to: $_showErrorLogs',
      name: 'AdvancedSettingsScreen',
      level: 0, // INFO
      time: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Logs Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SwitchListTile(
              title: const Text('Show Error Logs'),
              subtitle: const Text(
                'Show logs with status "error" in the logs list',
              ),
              value: _showErrorLogs,
              onChanged: (bool value) => _toggleErrorLogs(value),
            ),
          ],
        ),
      ),
    );
  }
}
