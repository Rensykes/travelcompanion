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
String _$allVisitsHash() => r'0d3f885c77f60871a6607990f1f02f034effeda7';

/// See also [allVisits].
@ProviderFor(allVisits)
final allVisitsProvider =
    AutoDisposeStreamProvider<List<CountryVisit>>.internal(
  allVisits,
  name: r'allVisitsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allVisitsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllVisitsRef = AutoDisposeStreamProviderRef<List<CountryVisit>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
