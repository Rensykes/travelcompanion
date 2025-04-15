import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:country_flags/country_flags.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:trackie/data/models/one_time_visit.dart';
import 'package:trackie/presentation/bloc/travel_history/travel_history_cubit.dart';
import 'package:trackie/presentation/bloc/travel_history/travel_history_state.dart';
import 'package:trackie/core/utils/data_refresh_util.dart';

class TravelHistoryScreen extends StatelessWidget {
  const TravelHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel History'),
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<TravelHistoryCubit, TravelHistoryState>(
        builder: (context, state) {
          if (state is TravelHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TravelHistoryLoaded) {
            return _buildTravelTimeline(context, state.visits);
          } else if (state is TravelHistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        DataRefreshUtil.refreshAllData(context: context),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No travel history available'));
        },
      ),
    );
  }

  Widget _buildTravelTimeline(BuildContext context, List<OneTimeVisit> visits) {
    if (visits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No travel history yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Start adding your trips to see your travel timeline here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('MMM d, yyyy');

    // Reverse the order to show most recent at the top
    final reversedVisits = visits.reversed.toList();

    return RefreshIndicator(
      onRefresh: () async {
        DataRefreshUtil.refreshAllData(context: context);
        return;
      },
      child: ListView.builder(
        itemCount: reversedVisits.length,
        itemBuilder: (context, index) {
          final visit = reversedVisits[index];
          final isFirst = index == 0;
          final isLast = index == reversedVisits.length - 1;

          return TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.2,
            isFirst: isFirst,
            isLast: isLast,
            indicatorStyle: IndicatorStyle(
              width: 40,
              height: 40,
              indicator: _CountryIndicator(countryCode: visit.countryCode),
            ),
            endChild: Container(
              constraints: const BoxConstraints(minHeight: 100),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          visit.countryCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (visit.isCurrent)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Current',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.flight_land,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Arrived: ${dateFormat.format(visit.entryDate)}',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (visit.exitDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.flight_takeoff,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Departed: ${dateFormat.format(visit.exitDate!)}',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${visit.daysSpent} ${visit.daysSpent == 1 ? 'day' : 'days'} spent',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${visit.locationLogs.length} log entries',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CountryIndicator extends StatelessWidget {
  final String countryCode;

  const _CountryIndicator({required this.countryCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Center(
        child: CountryFlag.fromCountryCode(
          countryCode,
          height: 30,
          width: 30,
          shape: const Circle(),
        ),
      ),
    );
  }
}
