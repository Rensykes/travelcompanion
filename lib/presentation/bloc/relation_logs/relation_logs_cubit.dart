import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/relation_logs/relation_logs_state.dart';

class RelationLogsCubit extends Cubit<RelationLogsState> {
  final LocationLogsRepository _repository;
  String? _currentCountryCode;

  RelationLogsCubit(this._repository) : super(RelationLogsInitial());

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

  Future<void> refresh() async {
    if (_currentCountryCode != null) {
      await loadLogsForCountry(_currentCountryCode!);
    }
  }
}
