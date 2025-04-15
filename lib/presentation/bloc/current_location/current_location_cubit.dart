import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/application/services/sim_info_service.dart';
import 'current_location_state.dart';
import 'dart:developer' as dev;

class CurrentLocationCubit extends Cubit<CurrentLocationState> {
  CurrentLocationCubit() : super(const CurrentLocationInitial());

  /// Detect the current country based on SIM/network information
  Future<void> detectCurrentCountry() async {
    try {
      emit(const CurrentLocationLoading());

      final isoCode = await SimInfoService.getIsoCode();

      emit(CurrentLocationLoaded(isoCode));
    } catch (e) {
      dev.log('Error detecting current country: $e');
      emit(CurrentLocationError('Could not detect location: ${e.toString()}'));
    }
  }

  /// Check if there's a current country code available
  bool hasCurrentCountry() {
    final currentState = state;
    return currentState is CurrentLocationLoaded &&
        currentState.isoCode != null;
  }

  /// Get the current country ISO code if available
  String? getCurrentCountryCode() {
    final currentState = state;
    return currentState is CurrentLocationLoaded ? currentState.isoCode : null;
  }
}
