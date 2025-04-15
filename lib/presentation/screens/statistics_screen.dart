import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tab_container/tab_container.dart';
import 'package:trackie/data/models/one_time_visit.dart';
import 'package:trackie/presentation/bloc/travel_history/travel_history_cubit.dart';
import 'package:trackie/presentation/bloc/travel_history/travel_history_state.dart';
import 'package:trackie/core/utils/data_refresh_util.dart';
import 'package:country_flags/country_flags.dart';
import 'package:intl/intl.dart';
import 'package:trackie/data/datasource/database.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_state.dart';
import 'package:trackie/presentation/widgets/gradient_background.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Remove late initialization to prevent errors
  late TextTheme textTheme;
  int _touchedIndex = -1;

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
    final colorScheme = Theme.of(context).colorScheme;
    // Initialize textTheme here to ensure it's always available
    textTheme = Theme.of(context).textTheme;

    return GradientScaffold(
      floatingActionButton: null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TabContainer(
                color: colorScheme.surfaceVariant,
                tabEdge: TabEdge.top,
                curve: Curves.easeInOut,
                tabExtent: 50,
                childPadding: const EdgeInsets.all(16.0),
                selectedTextStyle: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                unselectedTextStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14.0,
                ),
                tabs: _getTabs(context),
                children: _getChildren(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getTabs(BuildContext context) => <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart,
                size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 2),
            Text(
              'Countries',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart,
                size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 2),
            Text(
              'Timeline',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.donut_large,
                size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 2),
            Text(
              'Status',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart,
                size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 2),
            Text(
              'Activity',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map,
                size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 2),
            Text(
              'Overview',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ];

  List<Widget> _getChildren(BuildContext context) => <Widget>[
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
          return _buildCountryPieChart(state.visits);
        } else {
          return _buildEmptyState('No country visit data available');
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
          return _buildDurationBarChart(state.visits);
        } else {
          return _buildEmptyState('No travel timeline data available');
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
          return _buildStatusPieChart(state.logs);
        } else {
          return _buildEmptyState('No location log data available');
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
          return _buildMonthlyLineChart(state.logs);
        } else {
          return _buildEmptyState('No monthly activity data available');
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
                  _buildStatCard(
                    title: 'Countries Visited',
                    value: countriesCount.toString(),
                    icon: Icons.public,
                    color: Colors.blue.shade400,
                  ),
                  _buildStatCard(
                    title: 'Total Days',
                    value: totalDays.toString(),
                    icon: Icons.calendar_today,
                    color: Colors.purple.shade400,
                  ),
                  _buildStatCard(
                    title: 'Individual Visits',
                    value: visitsCount.toString(),
                    icon: Icons.flight_takeoff,
                    color: Colors.orange.shade400,
                  ),
                  _buildStatCard(
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 16),
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Country pie chart implementation
  Widget _buildCountryPieChart(List<OneTimeVisit> visits) {
    final colorScheme = Theme.of(context).colorScheme;

    // Group by country and calculate total days
    final countriesData = <String, int>{};
    int totalDays = 0;

    for (var visit in visits) {
      countriesData[visit.countryCode] =
          (countriesData[visit.countryCode] ?? 0) + visit.daysSpent;
      totalDays += visit.daysSpent;
    }

    // Sort by number of days (descending)
    final sortedEntries = countriesData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Card - First row
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Time Spent by Country',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Total: $totalDays days',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      'Percentage of total travel time in each country',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pie Chart - Second row (without card)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                height: 300, // Fixed height for the chart
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 1,
                    centerSpaceRadius: 20,
                    sections: _generatePieChartSections(
                        sortedEntries, totalDays, colorsList),
                  ),
                ),
              ),
            ),

            // Country List - Third row
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                height: 300, // Fixed height for the list
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: sortedEntries.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 70),
                  itemBuilder: (context, index) {
                    final entry = sortedEntries[index];
                    final countryCode = entry.key;
                    final days = entry.value;
                    final color = colorsList[index % colorsList.length];
                    final percentage = (days / totalDays) * 100;

                    return ListTile(
                      dense: true,
                      horizontalTitleGap: 8,
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          CountryFlag.fromCountryCode(
                            countryCode,
                            width: 24,
                            height: 16,
                            shape: const RoundedRectangle(6),
                          ),
                        ],
                      ),
                      title: Text(
                        countryCode,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Text(
                        '$days days (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections(
      List<MapEntry<String, int>> entries,
      int totalDays,
      List<Color> colorsList) {
    return List.generate(
      entries.length > 8
          ? 8
          : entries.length, // Limit to maximum 8 sections for readability
      (i) {
        final entry = entries[i];
        final isTouched = i == _touchedIndex;
        final fontSize = isTouched ? 14.0 : 12.0;
        final radius = isTouched ? 110.0 : 100.0;
        final badgeSize = isTouched ? 32.0 : 26.0;
        final percentage = (entry.value / totalDays) * 100;
        final color = colorsList[i % colorsList.length];

        return PieChartSectionData(
          color: color,
          value: entry.value.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black38, blurRadius: 2)],
          ),
          badgeWidget: _CountryBadge(
            countryCode: entry.key,
            size: badgeSize,
          ),
          badgePositionPercentageOffset: .80,
        );
      },
    );
  }

  // Custom badge widget for country flags
  Widget _CountryBadge({required String countryCode, required double size}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(1, 1),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .1),
      child: CountryFlag.fromCountryCode(
        countryCode,
        shape: const Circle(),
      ),
    );
  }

  // Duration bar chart implementation
  Widget _buildDurationBarChart(List<OneTimeVisit> visits) {
    final colorScheme = Theme.of(context).colorScheme;
    // Sort visits by entry date
    final sortedVisits = List<OneTimeVisit>.from(visits)
      ..sort((a, b) => a.entryDate.compareTo(b.entryDate));

    final visitDurationData = <BarChartGroupData>[];
    final visitLabels = <String>[];
    final dateFormat = DateFormat('MMM d');

    // Generate bar chart data
    for (int i = 0; i < sortedVisits.length; i++) {
      final visit = sortedVisits[i];
      visitDurationData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: visit.daysSpent.toDouble(),
              color: colorScheme.primary,
              width: 16,
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: (sortedVisits
                            .map((v) => v.daysSpent)
                            .reduce((a, b) => a > b ? a : b) *
                        1.2)
                    .toDouble(),
                color: colorScheme.primary.withOpacity(0.1),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
      visitLabels
          .add('${dateFormat.format(visit.entryDate)}\n${visit.countryCode}');
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Duration of Visits',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${sortedVisits.length} visits',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    'Number of days spent in each visit chronologically',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: sortedVisits.isNotEmpty
                        ? (sortedVisits
                                    .map((v) => v.daysSpent)
                                    .reduce((a, b) => a > b ? a : b) *
                                1.2)
                            .toDouble()
                        : 10,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < visitLabels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  children: [
                                    CountryFlag.fromCountryCode(
                                      sortedVisits[value.toInt()].countryCode,
                                      width: 16,
                                      height: 11,
                                      shape: const RoundedRectangle(6),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      visitLabels[value.toInt()],
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                          reservedSize: 60,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                    barGroups: visitDurationData,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Status pie chart implementation
  Widget _buildStatusPieChart(List<LocationLog> logs) {
    final colorScheme = Theme.of(context).colorScheme;

    // Count occurrences of each status
    final statusCounts = <String, int>{};

    for (var log in logs) {
      statusCounts[log.status] = (statusCounts[log.status] ?? 0) + 1;
    }

    // Sort by count (descending)
    final sortedEntries = statusCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Generate sections
    final sections = <PieChartSectionData>[];
    final colorsList = [
      Colors.blue.shade500,
      Colors.green.shade500,
      Colors.red.shade500,
      Colors.orange.shade500,
      Colors.purple.shade500,
    ];

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final color = colorsList[i % colorsList.length];
      final percentage = (entry.value / logs.length) * 100;

      sections.add(
        PieChartSectionData(
          color: color,
          value: entry.value.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 130,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Status Distribution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${logs.length} log entries',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    'Distribution of location log status types',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: AspectRatio(
              aspectRatio: 1.3,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  centerSpaceColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 3,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListView.separated(
                  itemCount: sortedEntries.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 48),
                  itemBuilder: (context, index) {
                    final entry = sortedEntries[index];
                    final color = colorsList[index % colorsList.length];
                    final percentage = (entry.value / logs.length) * 100;

                    return ListTile(
                      dense: true,
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Text(
                        '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Monthly activity line chart implementation
  Widget _buildMonthlyLineChart(List<LocationLog> logs) {
    final colorScheme = Theme.of(context).colorScheme;

    // Group logs by month
    final monthlyData = <int, int>{};
    final now = DateTime.now();
    final startDate = DateTime(now.year - 1, now.month, 1); // Last 12 months

    // Initialize all months with zero
    for (int i = 0; i < 12; i++) {
      final month = (startDate.month + i - 1) % 12 + 1;
      final year = startDate.year + (startDate.month + i - 1) ~/ 12;
      final monthKey = year * 100 + month; // Format: YYYYMM
      monthlyData[monthKey] = 0;
    }

    // Count logs per month
    for (var log in logs) {
      if (log.logDateTime.isAfter(startDate)) {
        final monthKey = log.logDateTime.year * 100 + log.logDateTime.month;
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + 1;
      }
    }

    // Sort by date
    final sortedEntries = monthlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Generate line chart spots
    final spots = <FlSpot>[];
    final labels = <String>[];
    final dateFormat = DateFormat('MMM yy');

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      spots.add(FlSpot(i.toDouble(), entry.value.toDouble()));

      final year = entry.key ~/ 100;
      final month = entry.key % 100;
      final date = DateTime(year, month, 1);
      labels.add(dateFormat.format(date));
    }

    // Calculate max Y value for proper scaling
    double maxY = 5; // Minimum default
    if (spots.isNotEmpty) {
      maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      maxY = maxY < 5 ? 5 : maxY * 1.2; // Ensure we have some space at the top
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Last 12 months',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    'Number of location entries per month',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 32, 8, 12),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: colorScheme.onSurface.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < labels.length) {
                              // Only show every other month to avoid crowding
                              if (value.toInt() % 2 == 0) {
                                return Text(
                                  labels[value.toInt()],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                );
                              }
                            }
                            return const SizedBox();
                          },
                          reservedSize: 24,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.onSurface.withOpacity(0.2),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: colorScheme.onSurface.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    minX: 0,
                    maxX: spots.length - 1.0,
                    minY: 0,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: colorScheme.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colorScheme.primary.withOpacity(0.4),
                              colorScheme.primary.withOpacity(0.1),
                            ],
                          ),
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: colorScheme.primary,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final year =
                                sortedEntries[spot.x.toInt()].key ~/ 100;
                            final month =
                                sortedEntries[spot.x.toInt()].key % 100;
                            final date = DateTime(year, month, 1);
                            final formattedDate =
                                DateFormat('MMMM yyyy').format(date);

                            return LineTooltipItem(
                              '${spot.y.toInt()} entries\n$formattedDate',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () async {
        DataRefreshUtil.refreshAllData(context: context);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 6),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Add travel data to see interesting visualizations here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      DataRefreshUtil.refreshAllData(context: context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
