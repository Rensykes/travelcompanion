// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_logs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$locationLogsRepositoryHash() =>
    r'3cad9075229a5eba60739388f396c6c29503fcd5';

/// See also [locationLogsRepository].
@ProviderFor(locationLogsRepository)
final locationLogsRepositoryProvider =
    AutoDisposeProvider<LocationLogsRepository>.internal(
  locationLogsRepository,
  name: r'locationLogsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$locationLogsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocationLogsRepositoryRef
    = AutoDisposeProviderRef<LocationLogsRepository>;
String _$allLogsHash() => r'2dba77a334566eda4e85988eae9e3b31364f3a86';

/// See also [allLogs].
@ProviderFor(allLogs)
final allLogsProvider = AutoDisposeStreamProvider<List<LocationLog>>.internal(
  allLogs,
  name: r'allLogsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allLogsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllLogsRef = AutoDisposeStreamProviderRef<List<LocationLog>>;
String _$filteredLogsHash() => r'073e55970cba0d588d9627a3b6bc84aa71a2c71a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [filteredLogs].
@ProviderFor(filteredLogs)
const filteredLogsProvider = FilteredLogsFamily();

/// See also [filteredLogs].
class FilteredLogsFamily extends Family<AsyncValue<List<LocationLog>>> {
  /// See also [filteredLogs].
  const FilteredLogsFamily();

  /// See also [filteredLogs].
  FilteredLogsProvider call({
    required bool showErrorLogs,
  }) {
    return FilteredLogsProvider(
      showErrorLogs: showErrorLogs,
    );
  }

  @override
  FilteredLogsProvider getProviderOverride(
    covariant FilteredLogsProvider provider,
  ) {
    return call(
      showErrorLogs: provider.showErrorLogs,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredLogsProvider';
}

/// See also [filteredLogs].
class FilteredLogsProvider
    extends AutoDisposeFutureProvider<List<LocationLog>> {
  /// See also [filteredLogs].
  FilteredLogsProvider({
    required bool showErrorLogs,
  }) : this._internal(
          (ref) => filteredLogs(
            ref as FilteredLogsRef,
            showErrorLogs: showErrorLogs,
          ),
          from: filteredLogsProvider,
          name: r'filteredLogsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredLogsHash,
          dependencies: FilteredLogsFamily._dependencies,
          allTransitiveDependencies:
              FilteredLogsFamily._allTransitiveDependencies,
          showErrorLogs: showErrorLogs,
        );

  FilteredLogsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.showErrorLogs,
  }) : super.internal();

  final bool showErrorLogs;

  @override
  Override overrideWith(
    FutureOr<List<LocationLog>> Function(FilteredLogsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredLogsProvider._internal(
        (ref) => create(ref as FilteredLogsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        showErrorLogs: showErrorLogs,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<LocationLog>> createElement() {
    return _FilteredLogsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredLogsProvider &&
        other.showErrorLogs == showErrorLogs;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, showErrorLogs.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredLogsRef on AutoDisposeFutureProviderRef<List<LocationLog>> {
  /// The parameter `showErrorLogs` of this provider.
  bool get showErrorLogs;
}

class _FilteredLogsProviderElement
    extends AutoDisposeFutureProviderElement<List<LocationLog>>
    with FilteredLogsRef {
  _FilteredLogsProviderElement(super.provider);

  @override
  bool get showErrorLogs => (origin as FilteredLogsProvider).showErrorLogs;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
