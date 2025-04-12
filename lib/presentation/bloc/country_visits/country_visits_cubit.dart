import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/data/repositories/country_visits_repository.dart';
import 'package:trackie/presentation/bloc/country_visits/country_visits_state.dart';

class CountryVisitsCubit extends Cubit<CountryVisitsState> {
  final CountryVisitsRepository _repository;

  CountryVisitsCubit(this._repository) : super(CountryVisitsInitial()) {
    loadVisits();
  }

  Future<void> loadVisits() async {
    emit(CountryVisitsLoading());
    try {
      final visits = await _repository.getAllCountryVisits();
      emit(CountryVisitsLoaded(visits));
    } catch (e) {
      emit(CountryVisitsError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadVisits();
  }
}
