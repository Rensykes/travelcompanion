import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_provider.g.dart';

@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

@riverpod
class ShowErrorLogs extends _$ShowErrorLogs {
  @override
  Future<bool> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return prefs.getBool('showErrorLogs') ?? true;
  }

  Future<void> toggle() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final currentValue = state.value ?? true;
    state = AsyncData(!currentValue);
    await prefs.setBool('showErrorLogs', !currentValue);
  }

  Future<void> set(bool value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    state = AsyncData(value);
    await prefs.setBool('showErrorLogs', value);
  }
}
