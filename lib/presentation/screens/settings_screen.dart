import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/presentation/controllers/settings_screen_controller.dart';
import 'package:trackie/presentation/screens/advanced_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  final Function(bool isDark, bool useSystemTheme) onThemeChanged;

  const SettingsScreen({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the settings controller state
    final settingsStateAsync = ref.watch(settingsScreenControllerProvider);

    // Get the controller
    final controller = ref.read(settingsScreenControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsStateAsync.when(
        data: (settings) => _buildSettingsUI(context, settings, controller),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSettingsUI(
    BuildContext context,
    SettingsScreenState settings,
    SettingsScreenController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Use System Theme'),
            value: settings.useSystemTheme,
            onChanged: (bool value) {
              controller.toggleSystemTheme(value);
              onThemeChanged(
                settings.useSystemTheme ? false : settings.isDarkMode,
                value,
              );
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged:
                settings.useSystemTheme
                    ? null // Disable this switch if using system theme
                    : (bool value) {
                      controller.toggleDarkMode(value);
                      onThemeChanged(value, settings.useSystemTheme);
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
            onPressed: () => controller.cleanupDatabase(context),
            child: const Text('Clean up Database'),
          ),
        ],
      ),
    );
  }
}
