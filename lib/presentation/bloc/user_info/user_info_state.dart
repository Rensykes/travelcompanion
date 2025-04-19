import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// State for the UserInfoCubit
@immutable
abstract class UserInfoState extends Equatable {
  const UserInfoState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the UserInfoCubit
class UserInfoInitial extends UserInfoState {}

/// Loading state when fetching user information
class UserInfoLoading extends UserInfoState {}

/// State when user information is loaded successfully
class UserInfoLoaded extends UserInfoState {
  final String name;
  final String countryCode;

  const UserInfoLoaded({
    required this.name,
    required this.countryCode,
  });

  @override
  List<Object?> get props => [name, countryCode];

  /// Create a copy of this state with optional new values
  UserInfoLoaded copyWith({
    String? name,
    String? countryCode,
  }) {
    return UserInfoLoaded(
      name: name ?? this.name,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}

/// State when user information is not available
class UserInfoNotFound extends UserInfoState {}

/// State when there's an error fetching user information
class UserInfoError extends UserInfoState {
  final String message;

  const UserInfoError(this.message);

  @override
  List<Object?> get props => [message];
}
