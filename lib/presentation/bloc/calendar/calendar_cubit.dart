import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/application/services/location_service.dart';
import 'package:trackie/presentation/bloc/calendar/calendar_state.dart';
import 'package:trackie/data/models/calendar_day_data.dart';

/// Manages the calendar view data throughout the application.
///
/// This cubit is responsible for loading, organizing, and presenting location logs
/// in a calendar format. It processes raw logs into a day-based structure,
/// tracking countries visited on each day and the first time each country was seen.
class CalendarCubit extends Cubit<CalendarState> {
  /// Service for location-related data operations
  final LocationService locationService;

  /// Creates a CalendarCubit with the required location service.
  ///
  /// Parameters:
  /// - [locationService]: Service for retrieving location log data
  CalendarCubit({
    required this.locationService,
  }) : super(const CalendarState());

  /// Loads and processes calendar data from location logs.
  ///
  /// This method:
  /// 1. Fetches all location logs
  /// 2. Groups logs by day
  /// 3. For each day, tracks all countries visited and their first seen times
  /// 4. Emits a state with the processed calendar data
  ///
  /// Detailed logging is included to track the data loading process.
  Future<void> loadCalendarData() async {
    emit(state.copyWith(isLoading: true));
    try {
      log(
        "🗓️ Loading calendar data",
        name: 'CalendarCubit',
        level: 0, // INFO
        time: DateTime.now(),
      );

      // Get all location logs using the location service
      final allLogs = await locationService.locationLogsRepository.getAllLogs();

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

          // Add this country to the set if it doesn't exist
          dayData[normalizedDate]!.countryCodes.add(log.countryCode!);

          // Update first seen time for this country if this log is earlier
          if (!dayData[normalizedDate]!
                  .firstSeenTimes
                  .containsKey(log.countryCode!) ||
              log.logDateTime.isBefore(
                  dayData[normalizedDate]!.firstSeenTimes[log.countryCode!]!)) {
            dayData[normalizedDate]!.firstSeenTimes[log.countryCode!] =
                log.logDateTime;
          }
        } else {
          // Create new day data with initial country
          dayData[normalizedDate] = CalendarDayData(
            countryCodes: {log.countryCode!},
            firstSeenTimes: {log.countryCode!: log.logDateTime},
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

  /// Selects a specific day in the calendar.
  ///
  /// Normalizes the date to ensure only year, month, and day are considered
  /// (ignoring time components), then updates the state with the selected day.
  ///
  /// Parameters:
  /// - [day]: The day to select in the calendar
  void selectDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    emit(state.copyWith(selectedDay: normalizedDay));
  }

  /// Refreshes the calendar data.
  ///
  /// This is a convenience method that delegates to [loadCalendarData].
  void refresh() {
    loadCalendarData();
  }
}
