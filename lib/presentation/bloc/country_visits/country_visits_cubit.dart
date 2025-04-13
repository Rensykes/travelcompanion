import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_state.dart';
import 'package:trackie/application/services/location_service.dart';
import 'package:trackie/application/services/sim_info_service.dart';
import 'package:trackie/core/utils/db_util.dart';

/// Manages country visit data and operations throughout the application.
///
/// This cubit handles loading, refreshing, adding, and deleting country visits.
/// It works with both the CountryVisitsRepository for data access and the
/// LocationService for higher-level operations that may affect multiple repositories.
class CountryVisitsCubit extends Cubit<CountryVisitsState> {
  final CountryVisitsRepository _repository;
  final LocationService _locationService;

  /// Creates a CountryVisitsCubit with the required dependencies.
  ///
  /// Immediately loads the country visits upon creation.
  ///
  /// Parameters:
  /// - [_repository]: Repository for accessing country visit data
  /// - [_locationService]: Service for performing location-related operations
  CountryVisitsCubit(this._repository, this._locationService)
      : super(const CountryVisitsInitial()) {
    loadVisits();
  }

  /// Loads all country visits from the repository.
  ///
  /// Preserves the current [isFetchingLocation] state while changing to
  /// loading state. Emits a [CountryVisitsLoaded] state on success or
  /// [CountryVisitsError] state on failure.
  Future<void> loadVisits() async {
    // Preserve isFetchingLocation state when changing to loading state
    final wasLoading = state.isFetchingLocation;
    emit(CountryVisitsLoading(isFetchingLocation: wasLoading));

    try {
      final visits = await _repository.getAllCountryVisits();
      emit(CountryVisitsLoaded(visits, isFetchingLocation: wasLoading));
    } catch (e) {
      emit(CountryVisitsError(e.toString(), isFetchingLocation: wasLoading));
    }
  }

  /// Refreshes the country visits data.
  ///
  /// This is a convenience method that delegates to [loadVisits].
  Future<void> refresh() async {
    await loadVisits();
  }

  /// Deletes a country visit and all associated location logs.
  ///
  /// Uses the [LocationService] to delete the country visit with the given
  /// [countryCode] and all associated location logs. Refreshes the visits list
  /// after successful deletion.
  ///
  /// Returns true if deletion was successful, false otherwise.
  Future<bool> deleteCountryVisit(String countryCode) async {
    try {
      await _locationService.deleteCountryVisit(countryCode);
      await loadVisits(); // Refresh the list after deletion
      return true;
    } catch (e) {
      final currentFetchingState = state.isFetchingLocation;
      emit(CountryVisitsError(e.toString(),
          isFetchingLocation: currentFetchingState));
      return false;
    }
  }

  /// Adds a new country visit with the specified country code and log source.
  ///
  /// Parameters:
  /// - [countryCode]: ISO code of the country to add
  /// - [logSource]: Source of the log entry (e.g., manual entry, automatic)
  /// - [showSnackBar]: Optional callback to display a snackbar notification
  ///
  /// Returns true if the country was added successfully, false otherwise.
  /// If provided, calls [showSnackBar] with success or error information.
  Future<bool> addCountry(
    String countryCode,
    String logSource, {
    Function(String, String, ContentType)? showSnackBar,
  }) async {
    try {
      await _locationService.addEntry(
        countryCode: countryCode,
        logSource: logSource,
      );
      await loadVisits(); // Refresh the list after addition

      // Show success message if a snackbar callback was provided
      if (showSnackBar != null) {
        showSnackBar(
          'Country Added!',
          'Added $countryCode to your visited countries 👌',
          ContentType.success,
        );
      }

      return true;
    } catch (e) {
      final currentFetchingState = state.isFetchingLocation;
      emit(CountryVisitsError(e.toString(),
          isFetchingLocation: currentFetchingState));

      // Show error message if a snackbar callback was provided
      if (showSnackBar != null) {
        _handleLocationError(showSnackBar);
      }

      return false;
    }
  }

  /// Detects the current country based on SIM/carrier information and adds it.
  ///
  /// Uses [SimInfoService] to detect the current country ISO code, then adds
  /// that country to the user's visits. Updates the UI to show the fetching state
  /// during the operation.
  ///
  /// Parameters:
  /// - [showSnackBar]: Callback to display result messages to the user
  ///
  /// Returns true if the country was successfully detected and added, false otherwise.
  Future<bool> detectAndAddCurrentCountry(
    Function(String, String, ContentType) showSnackBar,
  ) async {
    // Set isFetchingLocation to true
    _updateFetchingState(true);

    try {
      final isoCode = await SimInfoService.getIsoCode();

      if (isoCode != null) {
        final result = await addCountry(
          isoCode,
          DBUtils.manualEntry,
          showSnackBar: (title, message, type) {
            showSnackBar(
              'Location Retrieved!',
              'You are currently in: $isoCode 👌',
              ContentType.success,
            );
          },
        );
        return result;
      } else {
        _handleLocationError(showSnackBar);
        return false;
      }
    } catch (e) {
      _handleLocationError(showSnackBar);
      return false;
    } finally {
      // Reset isFetchingLocation to false
      _updateFetchingState(false);
    }
  }

  /// Updates the isFetchingLocation flag while preserving other state data.
  ///
  /// This helper method ensures the current state type and data are maintained
  /// while changing only the isFetchingLocation flag.
  ///
  /// Parameters:
  /// - [isFetching]: New value for the isFetchingLocation flag
  void _updateFetchingState(bool isFetching) {
    if (state is CountryVisitsLoaded) {
      final currentState = state as CountryVisitsLoaded;
      emit(CountryVisitsLoaded(currentState.visits,
          isFetchingLocation: isFetching));
    } else if (state is CountryVisitsError) {
      final currentState = state as CountryVisitsError;
      emit(CountryVisitsError(currentState.message,
          isFetchingLocation: isFetching));
    } else if (state is CountryVisitsLoading) {
      emit(CountryVisitsLoading(isFetchingLocation: isFetching));
    } else {
      emit(CountryVisitsInitial(isFetchingLocation: isFetching));
    }
  }

  /// Displays a standardized error message when location retrieval fails.
  ///
  /// Parameters:
  /// - [showSnackBar]: Callback to display the error message
  void _handleLocationError(
      Function(String, String, ContentType) showSnackBar) {
    showSnackBar(
      'Error',
      'Could not retrieve location. Please try again later.',
      ContentType.failure,
    );
  }
}
