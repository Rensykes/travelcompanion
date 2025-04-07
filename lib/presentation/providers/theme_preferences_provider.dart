import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trackie/presentation/providers/preferences_provider.dart';

part 'theme_preferences_provider.g.dart';

@riverpod
class ThemePreferences extends _$ThemePreferences {
  @override
  Future<ThemePreferencesState> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);

    // Get saved theme preferences or use defaults
    final useSystemTheme = prefs.getBool('useSystemTheme') ?? false;
    final isDarkMode = prefs.getBool('darkMode') ?? false;

    return ThemePreferencesState(
      isDarkMode: isDarkMode,
      useSystemTheme: useSystemTheme,
    );
  }

  Future<void> setThemeMode({bool? isDarkMode, bool? useSystemTheme}) async {
    if (!state.hasValue) return;

    final prefs = await ref.read(sharedPreferencesProvider.future);
    final currentState = state.value!;

    // Determine new state values
    final newIsDarkMode = isDarkMode ?? currentState.isDarkMode;
    final newUseSystemTheme = useSystemTheme ?? currentState.useSystemTheme;

    // If enabling system theme, reset dark mode
    final effectiveIsDarkMode = newUseSystemTheme ? false : newIsDarkMode;

    // Save preferences
    await prefs.setBool('useSystemTheme', newUseSystemTheme);
    await prefs.setBool('darkMode', effectiveIsDarkMode);

    // Update state
    state = AsyncValue.data(
      ThemePreferencesState(
        isDarkMode: effectiveIsDarkMode,
        useSystemTheme: newUseSystemTheme,
      ),
    );
  }
}

class ThemePreferencesState {
  final bool isDarkMode;
  final bool useSystemTheme;

  const ThemePreferencesState({
    required this.isDarkMode,
    required this.useSystemTheme,
  });

  ThemePreferencesState copyWith({bool? isDarkMode, bool? useSystemTheme}) {
    return ThemePreferencesState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
    );
  }
}
