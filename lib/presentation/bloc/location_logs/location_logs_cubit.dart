import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/data/repositories/location_logs_repository.dart';
import 'package:trackie/presentation/bloc/location_logs/location_logs_state.dart';

class LocationLogsCubit extends Cubit<LocationLogsState> {
  final LocationLogsRepository _repository;

  LocationLogsCubit(this._repository) : super(LocationLogsInitial()) {
    loadLogs();
  }

  Future<void> loadLogs() async {
    emit(LocationLogsLoading());
    try {
      final logs = await _repository.getAllLogs();
      emit(LocationLogsLoaded(logs));
    } catch (e) {
      emit(LocationLogsError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadLogs();
  }
}
