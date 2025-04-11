import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trackie/presentation/bloc/calendar/calendar_cubit.dart';
import 'package:trackie/presentation/bloc/calendar/calendar_state.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();

    // Load calendar data when screen initializes
    context.read<CalendarCubit>().loadCalendarData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Use a ListView instead of Column to prevent overflow
          return ListView(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  context.read<CalendarCubit>().selectDay(selectedDay);
                },
                eventLoader: (day) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  return state.dayData.containsKey(normalizedDay)
                      ? [state.dayData[normalizedDay]]
                      : [];
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return null;

                    final normalizedDate =
                        DateTime(date.year, date.month, date.day);
                    final dayData = state.dayData[normalizedDate];

                    if (dayData == null) return null;

                    return Positioned(
                      bottom: 1,
                      child: Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              _buildDayDetails(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDayDetails(CalendarState state) {
    final normalizedSelectedDay =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final dayData = state.dayData[normalizedSelectedDay];

    if (dayData == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('No location data for this day'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Important to prevent expansion
            children: [
              Text(
                'Location for ${_formatDate(normalizedSelectedDay)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.flag, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Country: ${dayData.countryCode}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'First seen on this day: ${_formatTime(dayData.firstSeenTime)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              if (dayData.logEntries.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Activity log:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                // Limit the height of the ListView to prevent overflow
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: dayData.logEntries.length,
                    itemBuilder: (context, index) {
                      final log = dayData.logEntries[index];
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text('Status: ${log.status}'),
                        subtitle: Text('Time: ${_formatTime(log.logDateTime)}'),
                        dense: true,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
