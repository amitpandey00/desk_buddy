import 'package:desk_buddy/core/clock/clock_provider.dart';
import 'package:desk_buddy/core/db/providers.dart';
import 'package:desk_buddy/core/window/window_bus.dart';
import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/categories/domain/category.dart';
import 'package:desk_buddy/features/reminders/application/reminder_commands.dart';
import 'package:desk_buddy/features/reminders/data/log_repository.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/wall_clock.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

// Dashboard-side providers. Every list here is a drift `.watch()` stream, so
// writes from either window (via WindowBus → markTablesUpdated) flow in.

@Riverpod(keepAlive: true)
WallClock wallClock(Ref ref) => const LocalWallClock();

/// Overridden in the dashboard's `main` with the started bus.
@Riverpod(keepAlive: true)
WindowBus windowBus(Ref ref) =>
    throw UnimplementedError('Override windowBusProvider');

/// "Now" (epoch ms), every second: drives live countdowns and day rollover.
@Riverpod(keepAlive: true)
Stream<int> now(Ref ref) async* {
  final clock = ref.watch(appClockProvider);
  yield clock.now().millisecondsSinceEpoch;
  yield* Stream<int>.periodic(
    const Duration(seconds: 1),
    (_) => clock.now().millisecondsSinceEpoch,
  );
}

/// Local midnight today; changes only when the day does.
@Riverpod(keepAlive: true)
int todayStart(Ref ref) {
  final wc = ref.watch(wallClockProvider);
  final now =
      ref.watch(nowProvider).value ??
      ref.read(appClockProvider).now().millisecondsSinceEpoch;
  return wc.startOfDay(now);
}

@Riverpod(keepAlive: true)
Stream<List<Reminder>> reminders(Ref ref) =>
    ref.watch(reminderRepositoryProvider).watchAll();

@Riverpod(keepAlive: true)
Stream<List<Category>> categories(Ref ref) =>
    ref.watch(categoryRepositoryProvider).watchAll();

@Riverpod(keepAlive: true)
Stream<AppSettings> settings(Ref ref) =>
    ref.watch(settingsRepositoryProvider).watch();

@Riverpod(keepAlive: true)
Stream<BuddyLook> look(Ref ref) =>
    ref.watch(settingsRepositoryProvider).watchLook();

@Riverpod(keepAlive: true)
Stream<List<LogEntry>> todayLog(Ref ref) =>
    ref.watch(logRepositoryProvider).watchSince(ref.watch(todayStartProvider));

/// Today and the 6 days before it.
@Riverpod(keepAlive: true)
Stream<List<LogEntry>> weekLog(Ref ref) {
  final start = ref
      .watch(wallClockProvider)
      .startOfDayOffset(ref.watch(todayStartProvider), -6);
  return ref.watch(logRepositoryProvider).watchSince(start);
}

/// History for streaks: as far back as the log is kept (90 days).
/// Streaks longer than that can't be counted.
@Riverpod(keepAlive: true)
Stream<List<LogEntry>> streakLog(Ref ref) {
  final start = ref
      .watch(wallClockProvider)
      .startOfDayOffset(ref.watch(todayStartProvider), -logRetentionDays);
  return ref.watch(logRepositoryProvider).watchSince(start);
}

@Riverpod(keepAlive: true)
Stream<bool> hasSampleHistory(Ref ref) =>
    ref.watch(logRepositoryProvider).watchHasSamples();

@Riverpod(keepAlive: true)
ReminderCommands reminderCommands(Ref ref) => ReminderCommands(
  ref.watch(reminderRepositoryProvider),
  ref.watch(logRepositoryProvider),
  clock: ref.watch(appClockProvider),
  wallClock: ref.watch(wallClockProvider),
);

/// Enabled reminders with a due time, soonest first.
List<Reminder> upcomingOf(List<Reminder> all) =>
    all.where((r) => r.enabled && r.nextDueAt != null).toList()
      ..sort((a, b) => a.nextDueAt!.compareTo(b.nextDueAt!));

/// The category with [id], or a neutral placeholder if it's gone.
Category categoryFor(List<Category> all, String id) =>
    all.where((c) => c.id == id).firstOrNull ??
    Category(
      id: id,
      name: Strings.uncategorized,
      emoji: Strings.defaultCategoryEmoji,
      colorHex: '#64748B',
    );
