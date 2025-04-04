import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/presentation/controllers/home_screen_controller.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:trackie/presentation/screens/entries_screen.dart';
import 'package:trackie/presentation/screens/logs_screen.dart';
import 'package:trackie/presentation/screens/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  final Function(bool, bool) onThemeChanged;
  final bool isDarkMode;
  final bool useSystemTheme;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.useSystemTheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeScreenControllerProvider);
    final controller = ref.read(homeScreenControllerProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => SettingsScreen(
                          isDarkMode: isDarkMode,
                          useSystemTheme: useSystemTheme,
                          onThemeChanged: onThemeChanged,
                        ),
                  ),
                ),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: 0,
          children: [EntriesScreen(), LogsScreen()],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Entries"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Logs"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            state.isFetchingLocation
                ? null
                : () {
                  controller.addCountry((title, message, status) {
                    SnackBarHelper.showSnackBar(context, title, message, status);
                  });
                },
        child:
            state.isFetchingLocation
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.add_location),
      ),
    );
  }
}
