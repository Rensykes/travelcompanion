import 'package:equatable/equatable.dart';
import 'package:trackie/data/datasource/database.dart';

abstract class CountryVisitsState extends Equatable {
  final bool isFetchingLocation;

  const CountryVisitsState({this.isFetchingLocation = false});

  @override
  List<Object?> get props => [isFetchingLocation];
}

class CountryVisitsInitial extends CountryVisitsState {
  const CountryVisitsInitial({super.isFetchingLocation});
}

class CountryVisitsLoading extends CountryVisitsState {
  const CountryVisitsLoading({super.isFetchingLocation});
}

class CountryVisitsLoaded extends CountryVisitsState {
  final List<CountryVisit> visits;

  const CountryVisitsLoaded(this.visits, {super.isFetchingLocation});

  @override
  List<Object?> get props => [visits, isFetchingLocation];
}

class CountryVisitsError extends CountryVisitsState {
  final String message;

  const CountryVisitsError(this.message, {super.isFetchingLocation});

  @override
  List<Object?> get props => [message, isFetchingLocation];
}
