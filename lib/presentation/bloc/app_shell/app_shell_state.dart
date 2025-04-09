import 'package:equatable/equatable.dart';

class AppShellState extends Equatable {
  final bool isFetchingLocation;

  const AppShellState({
    this.isFetchingLocation = false,
  });

  AppShellState copyWith({
    bool? isFetchingLocation,
  }) {
    return AppShellState(
      isFetchingLocation: isFetchingLocation ?? this.isFetchingLocation,
    );
  }

  @override
  List<Object?> get props => [isFetchingLocation];
}
