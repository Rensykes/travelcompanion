import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackie/presentation/controllers/home_screen_controller.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:trackie/presentation/screens/entries_screen.dart';
import 'package:trackie/presentation/screens/logs_screen.dart';
import 'package:trackie/presentation/screens/settings_screen.dart';
import 'package:trackie/presentation/widgets/custom_google_navbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
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
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes to foreground
      ref.read(homeScreenControllerProvider.notifier).refreshAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeScreenControllerProvider);
    final controller = ref.read(homeScreenControllerProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trackie')),
      body: SafeArea(
        child: IndexedStack(
          index: state.selectedTabIndex,
          children: [
            const EntriesScreen(),
            const LogsScreen(),
            SettingsScreen(onThemeChanged: widget.onThemeChanged),
          ],
        ),
      ),
      bottomNavigationBar: CustomGoogleNavBar(
        selectedIndex: state.selectedTabIndex,
        onTabChange: (index) {
          controller.changeTab(index);
        },
      ),
      floatingActionButton:
          state.selectedTabIndex != 2
              ? FloatingActionButton(
                onPressed:
                    state.isFetchingLocation
                        ? null
                        : () {
                          controller.addCountry((title, message, status) {
                            SnackBarHelper.showSnackBar(
                              context,
                              title,
                              message,
                              status,
                            );
                          });
                        },
                child:
                    state.isFetchingLocation
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.add_location),
              )
              : null,
    );
  }
}
