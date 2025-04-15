import 'package:equatable/equatable.dart';

abstract class CurrentLocationState extends Equatable {
  const CurrentLocationState();

  @override
  List<Object?> get props => [];
}

class CurrentLocationInitial extends CurrentLocationState {
  const CurrentLocationInitial();
}

class CurrentLocationLoading extends CurrentLocationState {
  const CurrentLocationLoading();
}

class CurrentLocationLoaded extends CurrentLocationState {
  final String? isoCode;

  const CurrentLocationLoaded(this.isoCode);

  @override
  List<Object?> get props => [isoCode];
}

class CurrentLocationError extends CurrentLocationState {
  final String message;

  const CurrentLocationError(this.message);

  @override
  List<Object?> get props => [message];
}
