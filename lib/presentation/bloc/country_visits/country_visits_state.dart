import 'package:equatable/equatable.dart';
import 'package:trackie/data/datasource/database.dart';

abstract class CountryVisitsState extends Equatable {
  const CountryVisitsState();

  @override
  List<Object?> get props => [];
}

class CountryVisitsInitial extends CountryVisitsState {}

class CountryVisitsLoading extends CountryVisitsState {}

class CountryVisitsLoaded extends CountryVisitsState {
  final List<CountryVisit> visits;

  const CountryVisitsLoaded(this.visits);

  @override
  List<Object?> get props => [visits];
}

class CountryVisitsError extends CountryVisitsState {
  final String message;

  const CountryVisitsError(this.message);

  @override
  List<Object?> get props => [message];
}
