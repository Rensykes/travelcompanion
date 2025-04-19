import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackie/core/services/user_info_service.dart';
import 'package:trackie/presentation/bloc/user_info/user_info_state.dart';

/// Cubit for managing user information
class UserInfoCubit extends Cubit<UserInfoState> {
  final UserInfoService _userInfoService;

  UserInfoCubit(this._userInfoService) : super(UserInfoInitial());

  /// Load user information from SharedPreferences
  Future<void> loadUserInfo() async {
    emit(UserInfoLoading());
    try {
      final hasInfo = await _userInfoService.hasUserInfo();
      if (!hasInfo) {
        emit(UserInfoNotFound());
        return;
      }

      final name = await _userInfoService.getUserName();
      final countryCode = await _userInfoService.getUserCountry();

      if (name != null && countryCode != null) {
        emit(UserInfoLoaded(name: name, countryCode: countryCode));
      } else {
        emit(UserInfoNotFound());
      }
    } catch (e) {
      emit(UserInfoError('Failed to load user info: $e'));
    }
  }

  /// Save user information to SharedPreferences
  Future<void> saveUserInfo({
    required String name,
    required String countryCode,
  }) async {
    emit(UserInfoLoading());
    try {
      final success = await _userInfoService.saveUserInfo(
        name: name,
        countryCode: countryCode,
      );

      if (success) {
        emit(UserInfoLoaded(name: name, countryCode: countryCode));
      } else {
        emit(const UserInfoError('Failed to save user info'));
      }
    } catch (e) {
      emit(UserInfoError('Error saving user info: $e'));
    }
  }

  /// Update user name
  Future<void> updateUserName(String name) async {
    final currentState = state;
    if (currentState is UserInfoLoaded) {
      emit(UserInfoLoading());
      try {
        final success = await _userInfoService.saveUserName(name);
        if (success) {
          emit(currentState.copyWith(name: name));
        } else {
          emit(const UserInfoError('Failed to update name'));
          emit(currentState); // Revert to previous state
        }
      } catch (e) {
        emit(UserInfoError('Error updating name: $e'));
        emit(currentState); // Revert to previous state
      }
    }
  }

  /// Update user country
  Future<void> updateUserCountry(String countryCode) async {
    final currentState = state;
    if (currentState is UserInfoLoaded) {
      emit(UserInfoLoading());
      try {
        final success = await _userInfoService.saveUserCountry(countryCode);
        if (success) {
          emit(currentState.copyWith(countryCode: countryCode));
        } else {
          emit(const UserInfoError('Failed to update country'));
          emit(currentState); // Revert to previous state
        }
      } catch (e) {
        emit(UserInfoError('Error updating country: $e'));
        emit(currentState); // Revert to previous state
      }
    }
  }

  /// Clear all user information
  Future<void> clearUserInfo() async {
    emit(UserInfoLoading());
    try {
      final success = await _userInfoService.clearUserInfo();
      if (success) {
        emit(UserInfoNotFound());
      } else {
        emit(const UserInfoError('Failed to clear user info'));
      }
    } catch (e) {
      emit(UserInfoError('Error clearing user info: $e'));
    }
  }
}
