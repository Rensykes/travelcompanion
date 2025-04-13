import 'package:equatable/equatable.dart';
import 'package:trackie/data/models/one_time_visit.dart';

abstract class TravelHistoryState extends Equatable {
  const TravelHistoryState();

  @override
  List<Object?> get props => [];
}

class TravelHistoryInitial extends TravelHistoryState {}

class TravelHistoryLoading extends TravelHistoryState {}

class TravelHistoryLoaded extends TravelHistoryState {
  final List<OneTimeVisit> visits;

  const TravelHistoryLoaded(this.visits);

  @override
  List<Object?> get props => [visits];
}

class TravelHistoryError extends TravelHistoryState {
  final String message;

  const TravelHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
