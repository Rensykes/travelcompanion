import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_state.dart';

/// Manages related location logs for a specific country.
///
/// This cubit is responsible for loading and refreshing logs that are
/// associated with a particular country. It helps display the detailed
/// history of a user's visits to a specific country.
class RelationLogsCubit extends Cubit<RelationLogsState> {
  final LocationLogsRepository _repository;

  /// Tracks the currently selected country code for refreshing
  String? _currentCountryCode;

  /// Creates a RelationLogsCubit with the required repository.
  ///
  /// Parameters:
  /// - [_repository]: Repository for accessing location log data
  RelationLogsCubit(this._repository) : super(RelationLogsInitial());

  /// Loads all location logs for a specific country.
  ///
  /// Stores the country code for potential refresh operations,
  /// then fetches all logs associated with that country.
  ///
  /// Parameters:
  /// - [countryCode]: The country code to load logs for
  ///
  /// Emits a [RelationLogsLoading] state during loading,
  /// followed by [RelationLogsLoaded] on success or
  /// [RelationLogsError] on failure.
  Future<void> loadLogsForCountry(String countryCode) async {
    _currentCountryCode = countryCode;
    emit(RelationLogsLoading());
    try {
      final logs = await _repository.getLogsByCountryCode(countryCode);
      emit(RelationLogsLoaded(logs));
    } catch (e) {
      emit(RelationLogsError(e.toString()));
    }
  }

  /// Refreshes the logs for the currently selected country.
  ///
  /// If no country is currently selected, this method does nothing.
  /// Otherwise, it reloads logs for the current country.
  Future<void> refresh() async {
    if (_currentCountryCode != null) {
      await loadLogsForCountry(_currentCountryCode!);
    }
  }
}
