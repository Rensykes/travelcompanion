// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_visits_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$countryVisitsRepositoryHash() =>
    r'5e9e6f14df6d1cae74ccd1cf4b97e6045aa87663';

/// See also [countryVisitsRepository].
@ProviderFor(countryVisitsRepository)
final countryVisitsRepositoryProvider =
    AutoDisposeProvider<CountryVisitsRepository>.internal(
  countryVisitsRepository,
  name: r'countryVisitsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$countryVisitsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CountryVisitsRepositoryRef
    = AutoDisposeProviderRef<CountryVisitsRepository>;
String _$countryVisitsHash() => r'2e35f0b3023262b33d287451a5bc2549cf974533';

/// See also [CountryVisits].
@ProviderFor(CountryVisits)
final countryVisitsProvider = AutoDisposeAsyncNotifierProvider<CountryVisits,
    List<CountryVisit>>.internal(
  CountryVisits.new,
  name: r'countryVisitsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$countryVisitsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CountryVisits = AutoDisposeAsyncNotifier<List<CountryVisit>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
