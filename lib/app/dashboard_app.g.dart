// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_app.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentSection)
final currentSectionProvider = CurrentSectionProvider._();

final class CurrentSectionProvider
    extends $NotifierProvider<CurrentSection, DashboardSection> {
  CurrentSectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSectionHash();

  @$internal
  @override
  CurrentSection create() => CurrentSection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardSection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardSection>(value),
    );
  }
}

String _$currentSectionHash() => r'3602c84d74dea8546dbe22b671b15c7521fd8df2';

abstract class _$CurrentSection extends $Notifier<DashboardSection> {
  DashboardSection build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DashboardSection, DashboardSection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DashboardSection, DashboardSection>,
              DashboardSection,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
