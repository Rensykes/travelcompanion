import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_state.dart';

/// Manages the location logs data throughout the application.
///
/// This cubit handles loading and refreshing location logs from the repository.
/// It provides access to all recorded location entries across the app.
class LocationLogsCubit extends Cubit<LocationLogsState> {
  final LocationLogsRepository _repository;

  /// Creates a LocationLogsCubit with the required repository.
  ///
  /// Immediately loads the location logs upon creation.
  ///
  /// Parameters:
  /// - [_repository]: Repository for accessing location log data
  LocationLogsCubit(this._repository) : super(LocationLogsInitial()) {
    loadLogs();
  }

  /// Loads all location logs from the repository.
  ///
  /// Emits a [LocationLogsLoading] state during loading,
  /// followed by [LocationLogsLoaded] on success or
  /// [LocationLogsError] on failure.
  Future<void> loadLogs() async {
    emit(LocationLogsLoading());
    try {
      final logs = await _repository.getAllLogs();
      emit(LocationLogsLoaded(logs));
    } catch (e) {
      emit(LocationLogsError(e.toString()));
    }
  }

  /// Refreshes the location logs data.
  ///
  /// This is a convenience method that delegates to [loadLogs].
  Future<void> refresh() async {
    await loadLogs();
  }
}
