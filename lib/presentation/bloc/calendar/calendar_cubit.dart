import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/calendar/calendar_state.dart';
import 'package:trackie/data/models/calendar_day_data.dart';

class CalendarCubit extends Cubit<CalendarState> {
  final LocationLogsRepository locationLogsRepository;

  CalendarCubit({
    required this.locationLogsRepository,
  }) : super(const CalendarState());

  Future<void> loadCalendarData() async {
    emit(state.copyWith(isLoading: true));
    try {
      log(
        "🗓️ Loading calendar data",
        name: 'CalendarCubit',
        level: 0, // INFO
        time: DateTime.now(),
      );

      // Get all location logs
      final allLogs = await locationLogsRepository.getAllLogs();

      // Group logs by day
      final Map<DateTime, CalendarDayData> dayData = {};

      for (final log in allLogs) {
        if (log.countryCode == null) continue;

        // Normalize date to just year, month, day
        final normalizedDate = DateTime(
          log.logDateTime.year,
          log.logDateTime.month,
          log.logDateTime.day,
        );

        if (dayData.containsKey(normalizedDate)) {
          // Add log to existing day
          dayData[normalizedDate]!.logEntries.add(log);

          // Update first seen time if this log is earlier
          if (log.logDateTime
              .isBefore(dayData[normalizedDate]!.firstSeenTime)) {
            dayData[normalizedDate] = CalendarDayData(
              countryCode: log.countryCode!,
              firstSeenTime: log.logDateTime,
              logEntries: dayData[normalizedDate]!.logEntries,
            );
          }
        } else {
          // Create new day data
          dayData[normalizedDate] = CalendarDayData(
            countryCode: log.countryCode!,
            firstSeenTime: log.logDateTime,
            logEntries: [log],
          );
        }
      }

      log(
        "📊 Loaded data for ${dayData.length} days",
        name: 'CalendarCubit',
        level: 0, // INFO
        time: DateTime.now(),
      );

      emit(state.copyWith(
        dayData: dayData,
        isLoading: false,
      ));
    } catch (e) {
      log(
        "❌ Error loading calendar data: $e",
        name: 'CalendarCubit',
        level: 3, // ERROR
        time: DateTime.now(),
        error: e,
      );
      emit(state.copyWith(
        isLoading: false,
        error: "Failed to load calendar data: $e",
      ));
    }
  }

  void selectDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    emit(state.copyWith(selectedDay: normalizedDay));
  }

  void refresh() {
    loadCalendarData();
  }
}
