// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(wallClock)
final wallClockProvider = WallClockProvider._();

final class WallClockProvider
    extends $FunctionalProvider<WallClock, WallClock, WallClock>
    with $Provider<WallClock> {
  WallClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wallClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wallClockHash();

  @$internal
  @override
  $ProviderElement<WallClock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WallClock create(Ref ref) {
    return wallClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WallClock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WallClock>(value),
    );
  }
}

String _$wallClockHash() => r'9207e8f1075edf4bdaae857be0b80331298668ad';

/// Overridden in the dashboard's `main` with the started bus.

@ProviderFor(windowBus)
final windowBusProvider = WindowBusProvider._();

/// Overridden in the dashboard's `main` with the started bus.

final class WindowBusProvider
    extends $FunctionalProvider<WindowBus, WindowBus, WindowBus>
    with $Provider<WindowBus> {
  /// Overridden in the dashboard's `main` with the started bus.
  WindowBusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'windowBusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$windowBusHash();

  @$internal
  @override
  $ProviderElement<WindowBus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WindowBus create(Ref ref) {
    return windowBus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WindowBus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WindowBus>(value),
    );
  }
}

String _$windowBusHash() => r'03e60663597b9e5a2b42655f96de7fe72556ccdb';

/// "Now" (epoch ms), every second: drives live countdowns and day rollover.

@ProviderFor(now)
final nowProvider = NowProvider._();

/// "Now" (epoch ms), every second: drives live countdowns and day rollover.

final class NowProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// "Now" (epoch ms), every second: drives live countdowns and day rollover.
  NowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nowHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return now(ref);
  }
}

String _$nowHash() => r'4fbcfc18dccb32506de500527a26cc475c8d0a67';

/// Local midnight today; changes only when the day does.

@ProviderFor(todayStart)
final todayStartProvider = TodayStartProvider._();

/// Local midnight today; changes only when the day does.

final class TodayStartProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Local midnight today; changes only when the day does.
  TodayStartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayStartProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayStartHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return todayStart(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$todayStartHash() => r'9f15d0c35b00632e9545eca189f77e35e9e26102';

@ProviderFor(reminders)
final remindersProvider = RemindersProvider._();

final class RemindersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Reminder>>,
          List<Reminder>,
          Stream<List<Reminder>>
        >
    with $FutureModifier<List<Reminder>>, $StreamProvider<List<Reminder>> {
  RemindersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remindersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remindersHash();

  @$internal
  @override
  $StreamProviderElement<List<Reminder>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Reminder>> create(Ref ref) {
    return reminders(ref);
  }
}

String _$remindersHash() => r'8355908c043003304ae9fdb8f8b1206464ca75e0';

@ProviderFor(categories)
final categoriesProvider = CategoriesProvider._();

final class CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          Stream<List<Category>>
        >
    with $FutureModifier<List<Category>>, $StreamProvider<List<Category>> {
  CategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Category>> create(Ref ref) {
    return categories(ref);
  }
}

String _$categoriesHash() => r'3b920668a6376c68f7ffc89b0ea170d803da4216';

@ProviderFor(settings)
final settingsProvider = SettingsProvider._();

final class SettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppSettings>,
          AppSettings,
          Stream<AppSettings>
        >
    with $FutureModifier<AppSettings>, $StreamProvider<AppSettings> {
  SettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsHash();

  @$internal
  @override
  $StreamProviderElement<AppSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppSettings> create(Ref ref) {
    return settings(ref);
  }
}

String _$settingsHash() => r'3b6219f1439e57bfda762caba6bd092e11961fb0';

@ProviderFor(look)
final lookProvider = LookProvider._();

final class LookProvider
    extends
        $FunctionalProvider<AsyncValue<BuddyLook>, BuddyLook, Stream<BuddyLook>>
    with $FutureModifier<BuddyLook>, $StreamProvider<BuddyLook> {
  LookProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lookProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lookHash();

  @$internal
  @override
  $StreamProviderElement<BuddyLook> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<BuddyLook> create(Ref ref) {
    return look(ref);
  }
}

String _$lookHash() => r'f555168c154d88586359997baaec70ed2db12e2c';

@ProviderFor(todayLog)
final todayLogProvider = TodayLogProvider._();

final class TodayLogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LogEntry>>,
          List<LogEntry>,
          Stream<List<LogEntry>>
        >
    with $FutureModifier<List<LogEntry>>, $StreamProvider<List<LogEntry>> {
  TodayLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayLogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayLogHash();

  @$internal
  @override
  $StreamProviderElement<List<LogEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LogEntry>> create(Ref ref) {
    return todayLog(ref);
  }
}

String _$todayLogHash() => r'3f11fe0a9e3186627175b1c90657a5d1cea94229';

/// Today and the 6 days before it.

@ProviderFor(weekLog)
final weekLogProvider = WeekLogProvider._();

/// Today and the 6 days before it.

final class WeekLogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LogEntry>>,
          List<LogEntry>,
          Stream<List<LogEntry>>
        >
    with $FutureModifier<List<LogEntry>>, $StreamProvider<List<LogEntry>> {
  /// Today and the 6 days before it.
  WeekLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weekLogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weekLogHash();

  @$internal
  @override
  $StreamProviderElement<List<LogEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LogEntry>> create(Ref ref) {
    return weekLog(ref);
  }
}

String _$weekLogHash() => r'bcdb2e8484a34a7546a711173f029ee00140d7e9';

/// History for streaks: as far back as the log is kept (90 days).
/// Streaks longer than that can't be counted.

@ProviderFor(streakLog)
final streakLogProvider = StreakLogProvider._();

/// History for streaks: as far back as the log is kept (90 days).
/// Streaks longer than that can't be counted.

final class StreakLogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LogEntry>>,
          List<LogEntry>,
          Stream<List<LogEntry>>
        >
    with $FutureModifier<List<LogEntry>>, $StreamProvider<List<LogEntry>> {
  /// History for streaks: as far back as the log is kept (90 days).
  /// Streaks longer than that can't be counted.
  StreakLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakLogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakLogHash();

  @$internal
  @override
  $StreamProviderElement<List<LogEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LogEntry>> create(Ref ref) {
    return streakLog(ref);
  }
}

String _$streakLogHash() => r'1433e59ec87f4860b63cd859977e07ee337996ef';

@ProviderFor(hasSampleHistory)
final hasSampleHistoryProvider = HasSampleHistoryProvider._();

final class HasSampleHistoryProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  HasSampleHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasSampleHistoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasSampleHistoryHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return hasSampleHistory(ref);
  }
}

String _$hasSampleHistoryHash() => r'745eda807f9123a31d1c5547746869d556c351ba';

@ProviderFor(reminderCommands)
final reminderCommandsProvider = ReminderCommandsProvider._();

final class ReminderCommandsProvider
    extends
        $FunctionalProvider<
          ReminderCommands,
          ReminderCommands,
          ReminderCommands
        >
    with $Provider<ReminderCommands> {
  ReminderCommandsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderCommandsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderCommandsHash();

  @$internal
  @override
  $ProviderElement<ReminderCommands> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReminderCommands create(Ref ref) {
    return reminderCommands(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderCommands value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderCommands>(value),
    );
  }
}

String _$reminderCommandsHash() => r'ac3a3809be26fd41687fb7de70e876fb56343ff6';
