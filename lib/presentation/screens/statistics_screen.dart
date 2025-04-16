import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/data/models/one_time_visit.dart';
import 'package:trackie/presentation/bloc/travel_history/travel_history_cubit.dart';
import 'package:trackie/presentation/bloc/travel_history/travel_history_state.dart';
import 'package:country_flags/country_flags.dart';
import 'package:intl/intl.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_state.dart';
import 'package:trackie/presentation/widgets/gradient_background.dart';
import 'package:trackie/presentation/widgets/statistics/stats_components.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Remove late initialization to prevent errors
  late TextTheme textTheme;

  @override
  void initState() {
    super.initState();

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TravelHistoryCubit>().loadTravelHistory();
      context.read<LocationLogsCubit>().loadLogs();
    });
  }

  @override
  void didChangeDependencies() {
    textTheme = Theme.of(context).textTheme;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize textTheme here to ensure it's always available
    textTheme = Theme.of(context).textTheme;

    return GradientScaffold(
      floatingActionButton: null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StatsTabContainer(
                tabs: _getTabs(),
                children: _getChildren(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getTabs() => <Widget>[
        const StatsTabItem(icon: Icons.pie_chart, label: 'Countries'),
        const StatsTabItem(icon: Icons.bar_chart, label: 'Timeline'),
        const StatsTabItem(icon: Icons.donut_large, label: 'Status'),
        const StatsTabItem(icon: Icons.show_chart, label: 'Activity'),
        const StatsTabItem(icon: Icons.map, label: 'Overview'),
      ];

  List<Widget> _getChildren() => <Widget>[
        _buildCountriesVisitChart(),
        _buildTimelineChart(),
        _buildStatusDistributionChart(),
        _buildMonthlyActivityChart(),
        _buildOverviewTab(),
      ];

  // Tab 1: Countries Pie Chart
  Widget _buildCountriesVisitChart() {
    return BlocBuilder<TravelHistoryCubit, TravelHistoryState>(
      builder: (context, state) {
        if (state is TravelHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TravelHistoryLoaded && state.visits.isNotEmpty) {
          // Group by country and calculate total days
          final countriesData = <String, int>{};
          int totalDays = 0;

          for (var visit in state.visits) {
            countriesData[visit.countryCode] =
                (countriesData[visit.countryCode] ?? 0) + visit.daysSpent;
            totalDays += visit.daysSpent;
          }

          final colorsList = [
            Colors.blue.shade500,
            Colors.green.shade500,
            Colors.red.shade500,
            Colors.amber.shade500,
            Colors.purple.shade500,
            Colors.teal.shade500,
            Colors.pink.shade500,
            Colors.indigo.shade500,
            Colors.orange.shade500,
            Colors.lime.shade700,
          ];

          return PieChartComponent(
            data: countriesData,
            colorsList: colorsList,
            title: 'Time Spent by Country',
            subtitle: 'Percentage of total travel time in each country',
            totalLabel: 'Total: $totalDays days',
            showCountryFlags: true,
          );
        } else {
          return const EmptyStatsView(
            message: 'No country visit data available',
          );
        }
      },
    );
  }

  // Tab 2: Timeline Bar Chart
  Widget _buildTimelineChart() {
    return BlocBuilder<TravelHistoryCubit, TravelHistoryState>(
      builder: (context, state) {
        if (state is TravelHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TravelHistoryLoaded && state.visits.isNotEmpty) {
          // Sort visits by entry date
          final sortedVisits = List<OneTimeVisit>.from(state.visits)
            ..sort((a, b) => a.entryDate.compareTo(b.entryDate));

          final dateFormat = DateFormat('MMM d');
          final barDataList = sortedVisits
              .map((visit) => BarData(
                    label: dateFormat.format(visit.entryDate),
                    value: visit.daysSpent,
                    countryCode: visit.countryCode,
                    date: visit.entryDate,
                  ))
              .toList();

          return BarChartComponent(
            data: barDataList,
            title: 'Duration of Visits',
            subtitle: 'Number of days spent in each visit chronologically',
            totalLabel: '${sortedVisits.length} visits',
            showCountryFlags: true,
            barColor: Theme.of(context).colorScheme.primary,
          );
        } else {
          return const EmptyStatsView(
            message: 'No travel timeline data available',
          );
        }
      },
    );
  }

  // Tab 3: Status Pie Chart
  Widget _buildStatusDistributionChart() {
    return BlocBuilder<LocationLogsCubit, LocationLogsState>(
      builder: (context, state) {
        if (state is LocationLogsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LocationLogsLoaded && state.logs.isNotEmpty) {
          // Count occurrences of each status
          final statusCounts = <String, int>{};

          for (var log in state.logs) {
            statusCounts[log.status] = (statusCounts[log.status] ?? 0) + 1;
          }

          final colorsList = [
            Colors.blue.shade500,
            Colors.green.shade500,
            Colors.red.shade500,
            Colors.orange.shade500,
            Colors.purple.shade500,
          ];

          return PieChartComponent(
            data: statusCounts,
            colorsList: colorsList,
            title: 'Status Distribution',
            subtitle: 'Distribution of location log status types',
            totalLabel: '${state.logs.length} log entries',
            showCountryFlags: false,
          );
        } else {
          return const EmptyStatsView(
            message: 'No location log data available',
          );
        }
      },
    );
  }

  // Tab 4: Monthly Activity Line Chart
  Widget _buildMonthlyActivityChart() {
    return BlocBuilder<LocationLogsCubit, LocationLogsState>(
      builder: (context, state) {
        if (state is LocationLogsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LocationLogsLoaded && state.logs.isNotEmpty) {
          // Group logs by month
          final monthlyData = <int, int>{};
          final now = DateTime.now();
          final startDate =
              DateTime(now.year - 1, now.month, 1); // Last 12 months

          // Initialize all months with zero
          for (int i = 0; i < 12; i++) {
            final month = (startDate.month + i - 1) % 12 + 1;
            final year = startDate.year + (startDate.month + i - 1) ~/ 12;
            final monthKey = year * 100 + month; // Format: YYYYMM
            monthlyData[monthKey] = 0;
          }

          // Count logs per month
          for (var log in state.logs) {
            if (log.logDateTime.isAfter(startDate)) {
              final monthKey =
                  log.logDateTime.year * 100 + log.logDateTime.month;
              monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + 1;
            }
          }

          // Sort by date
          final sortedEntries = monthlyData.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          // Convert to chart data
          final lineData = sortedEntries.map((entry) {
            final year = entry.key ~/ 100;
            final month = entry.key % 100;
            return MonthlyActivityData(
              date: DateTime(year, month, 1),
              value: entry.value,
            );
          }).toList();

          return LineChartComponent(
            data: lineData,
            title: 'Monthly Activity',
            subtitle: 'Number of location entries per month',
            totalLabel: 'Last 12 months',
            lineColor: Theme.of(context).colorScheme.primary,
          );
        } else {
          return const EmptyStatsView(
            message: 'No monthly activity data available',
          );
        }
      },
    );
  }

  // Tab 5: Overview tab with general travel stats
  Widget _buildOverviewTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<TravelHistoryCubit, TravelHistoryState>(
      builder: (context, state) {
        // Default values
        int countriesCount = 0;
        int totalDays = 0;
        int visitsCount = 0;
        String mostVisitedCountry = 'None';
        int longestStay = 0;

        if (state is TravelHistoryLoaded && state.visits.isNotEmpty) {
          // Calculate stats
          final visits = state.visits;
          final countryVisitCounts = <String, int>{};
          final countryDaysMap = <String, int>{};

          for (var visit in visits) {
            totalDays += visit.daysSpent;
            countryVisitCounts[visit.countryCode] =
                (countryVisitCounts[visit.countryCode] ?? 0) + 1;
            countryDaysMap[visit.countryCode] =
                (countryDaysMap[visit.countryCode] ?? 0) + visit.daysSpent;
          }

          countriesCount = countryVisitCounts.length;
          visitsCount = visits.length;

          if (countryVisitCounts.isNotEmpty) {
            final mostVisitedEntry = countryVisitCounts.entries
                .reduce((a, b) => a.value > b.value ? a : b);
            mostVisitedCountry = mostVisitedEntry.key;
          }

          if (countryDaysMap.isNotEmpty) {
            longestStay = countryDaysMap.values.reduce((a, b) => a > b ? a : b);
          }
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Travel Overview',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Stats cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatsCard(
                    title: 'Countries Visited',
                    value: countriesCount.toString(),
                    icon: Icons.public,
                    color: Colors.blue.shade400,
                  ),
                  StatsCard(
                    title: 'Total Days',
                    value: totalDays.toString(),
                    icon: Icons.calendar_today,
                    color: Colors.purple.shade400,
                  ),
                  StatsCard(
                    title: 'Individual Visits',
                    value: visitsCount.toString(),
                    icon: Icons.flight_takeoff,
                    color: Colors.orange.shade400,
                  ),
                  StatsCard(
                    title: 'Longest Stay',
                    value: '$longestStay days',
                    icon: Icons.home,
                    color: Colors.green.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Most visited section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Most Visited Country',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (mostVisitedCountry != 'None')
                            CountryFlag.fromCountryCode(
                              mostVisitedCountry,
                              height: 30,
                              width: 45,
                              shape: const RoundedRectangle(6),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mostVisitedCountry,
                              style: textTheme.headlineSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Instructions
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: colorScheme.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Analysis Tools',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Use the tabs to explore different aspects of your travel data:',
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        icon: Icons.pie_chart,
                        text: 'Countries - Time spent in each country',
                        color: colorScheme.onPrimaryContainer,
                      ),
                      _buildInfoItem(
                        icon: Icons.bar_chart,
                        text: 'Timeline - Duration of each country visit',
                        color: colorScheme.onPrimaryContainer,
                      ),
                      _buildInfoItem(
                        icon: Icons.donut_large,
                        text: 'Status - Distribution of location log statuses',
                        color: colorScheme.onPrimaryContainer,
                      ),
                      _buildInfoItem(
                        icon: Icons.show_chart,
                        text: 'Activity - Monthly travel activity levels',
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(
      {required IconData icon, required String text, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
