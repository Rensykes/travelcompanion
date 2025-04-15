import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackie/core/constants/route_constants.dart';
import 'package:trackie/core/utils/data_refresh_util.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_state.dart';
import 'package:country_flags/country_flags.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshData();
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
    }
  }

  void refreshData() {
    DataRefreshUtil.refreshAllData(context: context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshData,
          ),
        ],
      ),
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

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Travel Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
    return BlocBuilder<CountryVisitsCubit, CountryVisitsState>(
      builder: (context, state) {
        String? currentCountry;

        if (state is CountryVisitsLoaded && state.visits.isNotEmpty) {
          // For simplicity, let's assume the latest country is the current one
          final latestVisit = state.visits.first;
          currentCountry = latestVisit.countryCode;
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                if (currentCountry != null)
                  Row(
                    children: [
                      CountryFlag.fromCountryCode(
                        currentCountry,
                        width: 60,
                        height: 40,
                        borderRadius: 4,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentCountry,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_location, size: 16),
                            label: const Text('Update Location'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () {
                              context.push(RouteConstants.quickLogsAddFullPath);
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
                        const Text(
                          'No current location data',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_location),
                          label: const Text('Add Location'),
                          onPressed: () {
                            context.push(RouteConstants.quickLogsAddFullPath);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  () => context.push(RouteConstants.quickLogsAddFullPath),
                ),
                _buildActionButton(
                  context,
                  Icons.list_alt,
                  'View Countries',
                  () => context.push(RouteConstants.countriesFullPath),
                ),
                _buildActionButton(
                  context,
                  Icons.history,
                  'Timeline',
                  () => context.push(RouteConstants.travelHistoryFullPath),
                ),
                _buildActionButton(
                  context,
                  Icons.calendar_month,
                  'Calendar',
                  () => context.push(RouteConstants.calendar),
                ),
              ],
            ),
          ],
        ),
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

          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          context.push(RouteConstants.countriesFullPath);
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...recentVisits.map((visit) => ListTile(
                        leading: CountryFlag.fromCountryCode(
                          visit.countryCode,
                          width: 40,
                          height: 30,
                          borderRadius: 4,
                        ),
                        title: Text(visit.countryCode),
                        subtitle: Text('${visit.daysSpent} days'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          context.push(RouteConstants.buildRelationsRoute(
                              visit.countryCode));
                        },
                      )),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink(); // Empty widget if no data
      },
    );
  }
}
