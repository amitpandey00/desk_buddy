// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Opened in `main()` (it's async) and injected with
/// `appDataProvider.overrideWithValue(data)`.

@ProviderFor(appData)
final appDataProvider = AppDataProvider._();

/// Opened in `main()` (it's async) and injected with
/// `appDataProvider.overrideWithValue(data)`.

final class AppDataProvider
    extends $FunctionalProvider<AppData, AppData, AppData>
    with $Provider<AppData> {
  /// Opened in `main()` (it's async) and injected with
  /// `appDataProvider.overrideWithValue(data)`.
  AppDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDataHash();

  @$internal
  @override
  $ProviderElement<AppData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppData create(Ref ref) {
    return appData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppData>(value),
    );
  }
}

String _$appDataHash() => r'a0c9e32a11b50e1536b8a80293a5f25c2dd9c043';

/// Seed templates, loaded once at startup alongside [appData].

@ProviderFor(seedData)
final seedDataProvider = SeedDataProvider._();

/// Seed templates, loaded once at startup alongside [appData].

final class SeedDataProvider
    extends $FunctionalProvider<SeedData, SeedData, SeedData>
    with $Provider<SeedData> {
  /// Seed templates, loaded once at startup alongside [appData].
  SeedDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seedDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seedDataHash();

  @$internal
  @override
  $ProviderElement<SeedData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SeedData create(Ref ref) {
    return seedData(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeedData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeedData>(value),
    );
  }
}

String _$seedDataHash() => r'1086f78e3c7fb048cb1349d3b32ed0e569bfcd78';

@ProviderFor(dataChanges)
final dataChangesProvider = DataChangesProvider._();

final class DataChangesProvider
    extends $FunctionalProvider<DataChanges, DataChanges, DataChanges>
    with $Provider<DataChanges> {
  DataChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataChangesHash();

  @$internal
  @override
  $ProviderElement<DataChanges> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DataChanges create(Ref ref) {
    return dataChanges(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataChanges value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataChanges>(value),
    );
  }
}

String _$dataChangesHash() => r'1a47846046329b5403de82ea43f55fe0217bf86a';

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'4562d11820e5d4af00ec824c61d11400dc837a80';

@ProviderFor(reminderRepository)
final reminderRepositoryProvider = ReminderRepositoryProvider._();

final class ReminderRepositoryProvider
    extends
        $FunctionalProvider<
          ReminderRepository,
          ReminderRepository,
          ReminderRepository
        >
    with $Provider<ReminderRepository> {
  ReminderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReminderRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReminderRepository create(Ref ref) {
    return reminderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderRepository>(value),
    );
  }
}

String _$reminderRepositoryHash() =>
    r'08f96adce0fcd97e053dc88d730f81b092771d02';

@ProviderFor(logRepository)
final logRepositoryProvider = LogRepositoryProvider._();

final class LogRepositoryProvider
    extends $FunctionalProvider<LogRepository, LogRepository, LogRepository>
    with $Provider<LogRepository> {
  LogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logRepositoryHash();

  @$internal
  @override
  $ProviderElement<LogRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogRepository create(Ref ref) {
    return logRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogRepository>(value),
    );
  }
}

String _$logRepositoryHash() => r'22db16bce52fa95e97511c93c43ffbb2c07f113d';

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'3263fbf826ebeecc5305cfcf357843ebcbb0e6fd';
