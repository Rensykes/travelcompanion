import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/application/services/location_service.dart';
import 'package:trackie/presentation/bloc/travel_history/travel_history_state.dart';

/// Manages the travel history timeline data throughout the application.
///
/// This cubit is responsible for loading and refreshing the travel history,
/// which provides a chronological view of country visits. It uses the
/// LocationService to fetch organized visit data optimized for timeline display.
class TravelHistoryCubit extends Cubit<TravelHistoryState> {
  final LocationService _locationService;

  /// Creates a TravelHistoryCubit with the required service.
  ///
  /// Immediately loads the travel history upon creation.
  ///
  /// Parameters:
  /// - [_locationService]: Service for retrieving travel history data
  TravelHistoryCubit(this._locationService) : super(TravelHistoryInitial()) {
    loadTravelHistory();
  }

  /// Loads the travel history from the location service.
  ///
  /// Retrieves one-time visits that are optimized for timeline display.
  /// Emits a [TravelHistoryLoading] state during loading,
  /// followed by [TravelHistoryLoaded] on success or
  /// [TravelHistoryError] on failure.
  Future<void> loadTravelHistory() async {
    emit(TravelHistoryLoading());
    try {
      final visits = await _locationService.getOneTimeVisits();
      emit(TravelHistoryLoaded(visits));
    } catch (e) {
      emit(TravelHistoryError(e.toString()));
    }
  }

  /// Refreshes the travel history data.
  ///
  /// This is a convenience method that delegates to [loadTravelHistory].
  Future<void> refresh() async {
    await loadTravelHistory();
  }
}
