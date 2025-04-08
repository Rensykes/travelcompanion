// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relations_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$relationsScreenControllerHash() =>
    r'5795ab2ee15c8ae5e61eef7a59e0391035c198cd';

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

abstract class _$RelationsScreenController
    extends BuildlessAutoDisposeAsyncNotifier<List<LocationLog>> {
  late final String countryCode;

  FutureOr<List<LocationLog>> build(
    String countryCode,
  );
}

/// See also [RelationsScreenController].
@ProviderFor(RelationsScreenController)
const relationsScreenControllerProvider = RelationsScreenControllerFamily();

/// See also [RelationsScreenController].
class RelationsScreenControllerFamily
    extends Family<AsyncValue<List<LocationLog>>> {
  /// See also [RelationsScreenController].
  const RelationsScreenControllerFamily();

  /// See also [RelationsScreenController].
  RelationsScreenControllerProvider call(
    String countryCode,
  ) {
    return RelationsScreenControllerProvider(
      countryCode,
    );
  }

  @override
  RelationsScreenControllerProvider getProviderOverride(
    covariant RelationsScreenControllerProvider provider,
  ) {
    return call(
      provider.countryCode,
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
  String? get name => r'relationsScreenControllerProvider';
}

/// See also [RelationsScreenController].
class RelationsScreenControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<RelationsScreenController,
        List<LocationLog>> {
  /// See also [RelationsScreenController].
  RelationsScreenControllerProvider(
    String countryCode,
  ) : this._internal(
          () => RelationsScreenController()..countryCode = countryCode,
          from: relationsScreenControllerProvider,
          name: r'relationsScreenControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$relationsScreenControllerHash,
          dependencies: RelationsScreenControllerFamily._dependencies,
          allTransitiveDependencies:
              RelationsScreenControllerFamily._allTransitiveDependencies,
          countryCode: countryCode,
        );

  RelationsScreenControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.countryCode,
  }) : super.internal();

  final String countryCode;

  @override
  FutureOr<List<LocationLog>> runNotifierBuild(
    covariant RelationsScreenController notifier,
  ) {
    return notifier.build(
      countryCode,
    );
  }

  @override
  Override overrideWith(RelationsScreenController Function() create) {
    return ProviderOverride(
      origin: this,
      override: RelationsScreenControllerProvider._internal(
        () => create()..countryCode = countryCode,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        countryCode: countryCode,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<RelationsScreenController,
      List<LocationLog>> createElement() {
    return _RelationsScreenControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RelationsScreenControllerProvider &&
        other.countryCode == countryCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, countryCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RelationsScreenControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<LocationLog>> {
  /// The parameter `countryCode` of this provider.
  String get countryCode;
}

class _RelationsScreenControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<RelationsScreenController,
        List<LocationLog>> with RelationsScreenControllerRef {
  _RelationsScreenControllerProviderElement(super.provider);

  @override
  String get countryCode =>
      (origin as RelationsScreenControllerProvider).countryCode;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
