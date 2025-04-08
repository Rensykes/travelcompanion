import 'package:equatable/equatable.dart';
import 'package:trackie/data/datasource/database.dart';

abstract class LocationLogsState extends Equatable {
  const LocationLogsState();

  @override
  List<Object?> get props => [];
}

class LocationLogsInitial extends LocationLogsState {}

class LocationLogsLoading extends LocationLogsState {}

class LocationLogsLoaded extends LocationLogsState {
  final List<LocationLog> logs;

  const LocationLogsLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class LocationLogsError extends LocationLogsState {
  final String message;

  const LocationLogsError(this.message);

  @override
  List<Object?> get props => [message];
}
