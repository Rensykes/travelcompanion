// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'dc403fbb1d968c7d5ab4ae1721a29ffe173701c7';

/// See also [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider =
    AutoDisposeFutureProvider<SharedPreferences>.internal(
      sharedPreferences,
      name: r'sharedPreferencesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$sharedPreferencesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = AutoDisposeFutureProviderRef<SharedPreferences>;
String _$showErrorLogsHash() => r'3bdb865edb358d8f3a0137df043ae1db3b8d68c8';

/// See also [ShowErrorLogs].
@ProviderFor(ShowErrorLogs)
final showErrorLogsProvider =
    AutoDisposeAsyncNotifierProvider<ShowErrorLogs, bool>.internal(
      ShowErrorLogs.new,
      name: r'showErrorLogsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$showErrorLogsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShowErrorLogs = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
