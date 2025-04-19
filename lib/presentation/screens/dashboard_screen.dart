import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackie/core/constants/route_constants.dart';
import 'package:trackie/core/utils/data_refresh_util.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_state.dart';
import 'package:country_flags/country_flags.dart';
import 'package:trackie/presentation/bloc/current_location/current_location_cubit.dart';
import 'package:trackie/presentation/bloc/current_location/current_location_state.dart';
import 'package:trackie/presentation/widgets/gradient_background.dart';
import 'package:trackie/presentation/helpers/card_helper.dart';
import 'package:trackie/presentation/bloc/user_info/user_info_cubit.dart';
import 'package:trackie/presentation/bloc/user_info/user_info_state.dart';
import 'package:trackie/core/utils/app_themes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late final CurrentLocationCubit _currentLocationCubit;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentLocationCubit = context.read<CurrentLocationCubit>();

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshData();
      _currentLocationCubit.detectCurrentCountry();

      // Load user info
      context.read<UserInfoCubit>().loadUserInfo();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshData();
      _currentLocationCubit.detectCurrentCountry();
    }
  }

  void refreshData() {
    DataRefreshUtil.refreshAllData(context: context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GradientScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          refreshData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting section
                _buildGreetingSection(),

                const SizedBox(height: 24),

                // Stats Card
                _buildStatsCard(),

                const SizedBox(height: 24),

                // Current Location Section
                _buildCurrentCountrySection(),

                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActionsSection(context),

                const SizedBox(height: 24),

                // Recent Activity
                _buildRecentActivitySection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return BlocBuilder<UserInfoCubit, UserInfoState>(
      builder: (context, state) {
        String userName = 'there';

        if (state is UserInfoLoaded) {
          userName = state.name;
        } else if (state is UserInfoInitial || state is UserInfoNotFound) {
          // If user info is not loaded yet, trigger loading
          context.read<UserInfoCubit>().loadUserInfo();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
          child: Text(
            'Hi, $userName',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: AppThemes.lightGreen.withOpacity(0.8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCard() {
    return BlocBuilder<CountryVisitsCubit, CountryVisitsState>(
      builder: (context, state) {
        int countriesCount = 0;
        int totalDays = 0;

        if (state is CountryVisitsLoaded) {
          countriesCount = state.visits.length;
          totalDays =
              state.visits.fold(0, (sum, visit) => sum + visit.daysSpent);
        }

        return CardHelper.statCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Travel Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      GoRouter.of(context)
                          .go(RouteConstants.statisticsFullPath);
                    },
                    child: const Text('View Charts'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    Icons.public,
                    countriesCount.toString(),
                    'Countries Visited',
                  ),
                  _buildStatItem(
                    Icons.calendar_today,
                    totalDays.toString(),
                    'Days Traveled',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentCountrySection() {
    return BlocBuilder<CurrentLocationCubit, CurrentLocationState>(
      builder: (context, state) {
        return CardHelper.standardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (state is CurrentLocationLoading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Detecting your location...'),
                    ],
                  ),
                )
              else if (state is CurrentLocationLoaded && state.isoCode != null)
                Row(
                  children: [
                    CountryFlag.fromCountryCode(
                      state.isoCode!,
                      width: 60,
                      height: 40,
                      shape: const RoundedRectangle(6),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isoCode!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.add_location,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: const Text('Add to Log'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            context.go(RouteConstants.quickLogsAddFullPath);
                          },
                        ),
                      ],
                    ),
                  ],
                )
              else
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.location_off,
                          size: 40, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        state is CurrentLocationError
                            ? 'Error: ${state.message}'
                            : 'No current location data',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_location),
                        label: const Text('Add Location'),
                        onPressed: () {
                          context.go(RouteConstants.quickLogsAddFullPath);
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Detect Location'),
                        onPressed: () {
                          _currentLocationCubit.detectCurrentCountry();
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return CardHelper.highlightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 8.0,
            runSpacing: 16.0,
            children: [
              _buildActionButton(
                context,
                Icons.add_location,
                'Add Location',
                () => context.go(RouteConstants.quickLogsAddFullPath),
              ),
              _buildActionButton(
                context,
                Icons.list_alt,
                'View Countries',
                () => context.go(RouteConstants.countriesFullPath),
              ),
              _buildActionButton(
                context,
                Icons.history,
                'Timeline',
                () => context.go(RouteConstants.travelHistoryFullPath),
              ),
              _buildActionButton(
                context,
                Icons.calendar_month,
                'Calendar',
                () => context.go(RouteConstants.calendar),
              ),
              _buildActionButton(
                context,
                Icons.bar_chart,
                'Statistics',
                () =>
                    GoRouter.of(context).go(RouteConstants.statisticsFullPath),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 65,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return BlocBuilder<CountryVisitsCubit, CountryVisitsState>(
      builder: (context, state) {
        if (state is CountryVisitsLoaded && state.visits.isNotEmpty) {
          final recentVisits = state.visits.take(3).toList();

          final listItems = <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Countries',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go(RouteConstants.countriesFullPath);
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            ...recentVisits.map((visit) => ListTile(
                  leading: CountryFlag.fromCountryCode(
                    visit.countryCode,
                    width: 40,
                    height: 30,
                    shape: const RoundedRectangle(6),
                  ),
                  title: Text(visit.countryCode),
                  subtitle: Text('${visit.daysSpent} days'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.go(
                        RouteConstants.buildRelationsRoute(visit.countryCode));
                  },
                )),
          ];

          return CardHelper.listCard(
            children: listItems,
          );
        }

        return const SizedBox.shrink(); // Empty widget if no data
      },
    );
  }
}
