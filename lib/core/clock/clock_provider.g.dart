// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The only source of "now". Override with `Clock.fixed(...)` in tests.
/// (`const Clock()` reads `DateTime.now()`, which is why this folder is the
/// one place the guard test allows it.)

@ProviderFor(appClock)
final appClockProvider = AppClockProvider._();

/// The only source of "now". Override with `Clock.fixed(...)` in tests.
/// (`const Clock()` reads `DateTime.now()`, which is why this folder is the
/// one place the guard test allows it.)

final class AppClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  /// The only source of "now". Override with `Clock.fixed(...)` in tests.
  /// (`const Clock()` reads `DateTime.now()`, which is why this folder is the
  /// one place the guard test allows it.)
  AppClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appClockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return appClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$appClockHash() => r'b53dd2cd85a5712fc0384fbad71c154e4e2be381';
