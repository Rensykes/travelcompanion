import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:get_it/get_it.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/helpers/snackbar_helper.dart';
import 'package:trackie/presentation/screens/entries_screen.dart';
import 'package:trackie/presentation/screens/logs_screen.dart';
import 'package:trackie/presentation/screens/settings_screen.dart';
import 'package:trackie/presentation/widgets/custom_google_navbar.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/home/home_cubit.dart';
import 'package:trackie/presentation/bloc/home/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedTabIndex = 0;
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _homeCubit = HomeCubit(
      locationLogsRepository: GetIt.instance.get<LocationLogsRepository>(),
      countryVisitsRepository: GetIt.instance.get<CountryVisitsRepository>(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _homeCubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes to foreground
      refreshAllData();
    }
  }

  void refreshAllData() {
    context.read<LocationLogsCubit>().refresh();
    context.read<CountryVisitsCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeCubit,
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, homeState) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trackie')),
            body: SafeArea(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: const [
                  EntriesScreen(),
                  LogsScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
            bottomNavigationBar: CustomGoogleNavBar(
              selectedIndex: _selectedTabIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
            floatingActionButton: _selectedTabIndex != 2
                ? FloatingActionButton(
                    onPressed: homeState.isFetchingLocation
                        ? null
                        : () {
                            _homeCubit.addCountry(
                              (title, message, status) {
                                SnackBarHelper.showSnackBar(
                                  context,
                                  title,
                                  message,
                                  status,
                                );
                                // Ensure data is refreshed after adding country
                                refreshAllData();
                              },
                            );
                          },
                    child: homeState.isFetchingLocation
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.add_location),
                  )
                : null,
          );
        },
      ),
    );
  }
}
