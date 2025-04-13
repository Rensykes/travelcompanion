import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/calendar/calendar_cubit.dart';
import 'package:trackie/presentation/bloc/travel_history/travel_history_cubit.dart';

/// Utility class for refreshing data across multiple cubits
class DataRefreshUtil {
  /// Refreshes all data-related cubits (LocationLogs, CountryVisits, Calendar)
  ///
  /// If [context] is provided, will read the cubits from the BuildContext
  /// If [locationLogsCubit], [countryVisitsCubit], or [calendarCubit] are provided directly,
  /// they will be used instead of reading from context
  ///
  /// If [enableLogging] is true, will log refresh operations
  static void refreshAllData({
    BuildContext? context,
    LocationLogsCubit? locationLogsCubit,
    CountryVisitsCubit? countryVisitsCubit,
    CalendarCubit? calendarCubit,
    TravelHistoryCubit? travelHistoryCubit,
    bool enableLogging = false,
  }) {
    // Get cubits either from context or from parameters
    final locLogs = locationLogsCubit ?? context?.read<LocationLogsCubit>();
    final countryVisits =
        countryVisitsCubit ?? context?.read<CountryVisitsCubit>();
    final calendar = calendarCubit ?? context?.read<CalendarCubit>();
    final travelHistory =
        travelHistoryCubit ?? context?.read<TravelHistoryCubit>();

    // Refresh location logs
    if (locLogs != null) {
      if (enableLogging) {
        log('🔄 Refreshing LocationLogsCubit (instance: ${identityHashCode(locLogs)})');
      }
      locLogs.refresh();
    }

    // Refresh country visits
    if (countryVisits != null) {
      if (enableLogging) {
        log('🔄 Refreshing CountryVisitsCubit (instance: ${identityHashCode(countryVisits)})');
      }
      countryVisits.refresh();
    }

    // Refresh calendar
    if (calendar != null) {
      if (enableLogging) {
        log('🔄 Refreshing CalendarCubit (instance: ${identityHashCode(calendar)})');
      }
      calendar.refresh();
    }

    // Refresh travel history
    if (travelHistory != null) {
      if (enableLogging) {
        log('🔄 Refreshing CalendarCubit (instance: ${identityHashCode(travelHistory)})');
      }
      travelHistory.refresh();
    }

    if (enableLogging) {
      log('✅ Refresh completed for all cubits');
    }
  }
}
