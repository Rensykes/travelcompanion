import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isFetchingLocation;

  const HomeState({
    this.isFetchingLocation = false,
  });

  HomeState copyWith({
    bool? isFetchingLocation,
  }) {
    return HomeState(
      isFetchingLocation: isFetchingLocation ?? this.isFetchingLocation,
    );
  }

  @override
  List<Object?> get props => [isFetchingLocation];
}
