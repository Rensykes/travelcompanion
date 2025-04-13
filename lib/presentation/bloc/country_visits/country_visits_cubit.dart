import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_state.dart';
import 'package:trackie/application/services/location_service.dart';
import 'package:trackie/application/services/sim_info_service.dart';
import 'package:trackie/core/utils/db_util.dart';

class CountryVisitsCubit extends Cubit<CountryVisitsState> {
  final CountryVisitsRepository _repository;
  final LocationService _locationService;

  CountryVisitsCubit(this._repository, this._locationService)
      : super(const CountryVisitsInitial()) {
    loadVisits();
  }

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

  Future<void> refresh() async {
    await loadVisits();
  }

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

  /// Add a country visit with the specified country code and log source
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

  /// Detect and add the current country based on SIM/carrier information
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

  /// Helper method to update isFetchingLocation state while preserving other state data
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

  void _handleLocationError(
      Function(String, String, ContentType) showSnackBar) {
    showSnackBar(
      'Error',
      'Could not retrieve location. Please try again later.',
      ContentType.failure,
    );
  }
}
