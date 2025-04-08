import 'package:equatable/equatable.dart';
import 'package:trackie/data/datasource/database.dart';

abstract class RelationLogsState extends Equatable {
  const RelationLogsState();

  @override
  List<Object?> get props => [];
}

class RelationLogsInitial extends RelationLogsState {}

class RelationLogsLoading extends RelationLogsState {}

class RelationLogsLoaded extends RelationLogsState {
  final List<LocationLog> logs;

  const RelationLogsLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class RelationLogsError extends RelationLogsState {
  final String message;

  const RelationLogsError(this.message);

  @override
  List<Object?> get props => [message];
}
