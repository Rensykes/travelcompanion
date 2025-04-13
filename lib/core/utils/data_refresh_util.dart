import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_cubit.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_cubit.dart';
import 'package:trackie/presentation/bloc/calendar/calendar_cubit.dart';
import 'package:trackie/presentation/bloc/travel_history/travel_history_cubit.dart';

/// Utility class for refreshing data across multiple cubits in the application.
///
/// This utility provides a centralized way to refresh all data-related cubits,
/// ensuring consistent data synchronization across the app. It can use either
/// direct cubit instances or read them from a BuildContext.
class DataRefreshUtil {
  /// Refreshes all data-related cubits in the application.
  ///
  /// This method provides two ways to refresh data:
  ///
  /// 1. Context-based (recommended): Pass a [BuildContext] to read cubits from the widget tree.
  ///    This approach is more flexible but requires a valid mounted context.
  ///
  /// 2. Direct instance: Pass specific cubit instances directly.
  ///    This approach doesn't require a context but needs access to all cubits.
  ///
  /// If both context and direct instances are provided, the direct instances will be used.
  /// If [enableLogging] is true, refresh operations will be logged to the console.
  ///
  /// Example usage:
  /// ```dart
  /// // Context-based refresh (within a widget)
  /// DataRefreshUtil.refreshAllData(context: context);
  ///
  /// // Direct instance refresh (within a service or repository)
  /// DataRefreshUtil.refreshAllData(
  ///   locationLogsCubit: myLocationLogsCubit,
  ///   countryVisitsCubit: myCountryVisitsCubit,
  /// );
  /// ```
  ///
  /// IMPORTANT: When using [context], ensure that the widget is still mounted
  /// to avoid potential exceptions.
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
        log('🔄 Refreshing TravelHistoryCubit (instance: ${identityHashCode(travelHistory)})');
      }
      travelHistory.refresh();
    }

    if (enableLogging) {
      log('✅ Refresh completed for all cubits');
    }
  }
}
