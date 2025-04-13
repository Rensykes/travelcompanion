import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/application/services/location_service.dart';
import 'package:trackie/presentation/bloc/travel_history/travel_history_state.dart';

class TravelHistoryCubit extends Cubit<TravelHistoryState> {
  final LocationService _locationService;

  TravelHistoryCubit(this._locationService) : super(TravelHistoryInitial()) {
    loadTravelHistory();
  }

  Future<void> loadTravelHistory() async {
    emit(TravelHistoryLoading());
    try {
      final visits = await _locationService.getOneTimeVisits();
      emit(TravelHistoryLoaded(visits));
    } catch (e) {
      emit(TravelHistoryError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadTravelHistory();
  }
}
