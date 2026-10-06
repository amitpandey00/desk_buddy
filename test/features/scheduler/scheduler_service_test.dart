import 'package:clock/clock.dart';
import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/features/reminders/application/reminder_commands.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/application/alert_view.dart';
import 'package:desk_buddy/features/scheduler/application/scheduler_service.dart';
import 'package:desk_buddy/features/scheduler/engine/wall_clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

class FakeNotifier implements AlertNotifier {
  final shown = <AlertView>[];
  int dismissed = 0;
  void Function()? done;
  void Function()? snooze;

  @override
  Future<void> show(
    AlertView alert, {
    required void Function() onDone,
    required void Function() onSkip,
    required void Function() onSnooze,
  }) async {
    shown.add(alert);
    done = onDone;
    snooze = onSnooze;
  }

  @override
  Future<void> dismiss() async => dismissed++;
}

void main() {
  late AppData data;
  late DateTime now;
  late SchedulerService service;
  late FakeNotifier notifier;
  late int chimes;
  const wc = LocalWallClock();

  Future<void> settle() async {
    // Let drift streams and the effect queue run.
    for (var i = 0; i < 5; i++) {
      await pumpEventQueue();
    }
  }

  Future<void> advance(Duration d) async {
    now = now.add(d);
    await service.tick();
    await settle();
  }

  setUp(() async {
    now = testNow; // Tue 10:00
    data = await memoryData();
    await data.prepare(await realSeed());
    notifier = FakeNotifier();
    chimes = 0;
    service = SchedulerService(
      data,
      clock: Clock(() => now),
      chime: () async => chimes++,
      notifier: notifier,
    );
  });

  tearDown(() async {
    await service.dispose();
    await data.close();
  });

  Future<Reminder> seeded(int i) async => (await data.reminders.all())[i];

  /// Leaves only the first seeded reminder (Drink water, every 60 min,
  /// 08–22) enabled, so "advance an hour" means exactly one pop-up.
  Future<void> onlyFirst() async {
    for (final r in (await data.reminders.all()).skip(1)) {
      await data.reminders.save(r.copyWith(enabled: false, nextDueAt: null));
    }
  }

  test('start schedules the seeded reminders from now', () async {
    await service.start(autoTick: false);
    await settle();
    final water = await seeded(0); // interval 60, 08–22
    expect(
      water.nextDueAt,
      now.add(const Duration(hours: 1)).millisecondsSinceEpoch,
    );
    final meeting = await seeded(1); // 19:00 weekdays
    expect(
      DateTime.fromMillisecondsSinceEpoch(meeting.nextDueAt!),
      DateTime(2026, 10, 6, 19),
    );
  });

  test('fires with the filled message, goal pill and a chime', () async {
    await onlyFirst();
    await service.start(autoTick: false);
    await settle();
    await advance(const Duration(hours: 1));
    final a = service.current!;
    expect(a.reminder.title, 'Drink water');
    expect(a.message, 'Hey, there! Did you drink water?');
    expect(a.progress, '0 / 8 glasses today');
    expect(a.doneLabel, 'Yes!');
    expect(a.snoozeLabel, 'Remind me in 10 min');
    expect(a.propId, 'bottle');
    expect(chimes, 1);
    expect(notifier.shown, isEmpty, reason: 'buddy is visible');
  });

  test('done: logged in the database, rescheduled, bubble closed', () async {
    await onlyFirst();
    await service.start(autoTick: false);
    await settle();
    await advance(const Duration(hours: 1));
    now = now.add(const Duration(seconds: 7));
    await service.respond(LogAction.done);
    await settle();
    expect(service.current, isNull);
    final log = await data.log.since(0);
    expect(log.single.action, LogAction.done);
    expect(log.single.responseSeconds, 7);
    expect(
      (await seeded(0)).nextDueAt,
      now.add(const Duration(hours: 1)).millisecondsSinceEpoch,
    );
    // The next pop-up counts it.
    await advance(const Duration(hours: 1));
    expect(service.current!.progress, '1 / 8 glasses today');
  });

  test('{count} includes manual +1s', () async {
    final water = await seeded(0);
    await data.reminders.save(
      water.copyWith(messageTemplate: '{count}/{goal} {unit}'),
    );
    final commands = ReminderCommands(
      data.reminders,
      data.log,
      clock: Clock(() => now),
    );
    await commands.logManual(water);
    await commands.logManual(water);
    await service.start(autoTick: false);
    await settle();
    await service.testFire(water.id);
    await settle();
    expect(service.current!.message, '2/8 glasses');
    expect(service.current!.test, isTrue);
  });

  test('settings flow in: DND blocks, snooze length applies', () async {
    await onlyFirst();
    await service.start(autoTick: false);
    await settle();
    await data.settings.update(
      (s) => s.copyWith(doNotDisturb: true, snoozeMinutes: 30),
    );
    await settle();
    await advance(const Duration(hours: 2));
    expect(service.current, isNull);
    await data.settings.update((s) => s.copyWith(doNotDisturb: false));
    await settle();
    await advance(const Duration(seconds: 1));
    expect(service.current!.snoozeLabel, 'Remind me in 30 min');
    await service.respond(LogAction.snoozed);
    await settle();
    expect(
      (await seeded(0)).nextDueAt,
      now.add(const Duration(minutes: 30)).millisecondsSinceEpoch,
    );
  });

  test('sound off: no chime', () async {
    await onlyFirst();
    await data.settings.update((s) => s.copyWith(soundEnabled: false));
    await service.start(autoTick: false);
    await settle();
    await advance(const Duration(hours: 1));
    expect(service.current, isNotNull);
    expect(chimes, 0);
  });

  test('buddy hidden: a notification stands in, its buttons answer', () async {
    await onlyFirst();
    await data.settings.update((s) => s.copyWith(buddyVisible: false));
    await service.start(autoTick: false);
    await settle();
    await advance(const Duration(hours: 1));
    expect(notifier.shown.single.message, 'Hey, there! Did you drink water?');
    notifier.done!();
    await settle();
    expect((await data.log.since(0)).single.action, LogAction.done);
    expect(notifier.dismissed, greaterThan(0));
  });

  test('edits from "the other window" reschedule from now', () async {
    await onlyFirst();
    await service.start(autoTick: false);
    await settle();
    final commands = ReminderCommands(
      data.reminders,
      data.log,
      clock: Clock(() => now),
    );
    final water = await seeded(0);
    await commands.save(water.copyWith(everyMinutes: 5));
    await settle();
    await advance(const Duration(minutes: 5));
    expect(service.current?.reminder.id, water.id);
  });

  test('alerts stream emits show then hide', () async {
    await onlyFirst();
    await service.start(autoTick: false);
    await settle();
    final seen = <String?>[];
    service.alerts.listen((a) => seen.add(a?.reminder.title));
    await advance(const Duration(hours: 1));
    await service.respond(LogAction.done);
    await settle();
    expect(seen, ['Drink water', null]);
  });

  test('a failing effect is reported and the scheduler keeps going', () async {
    await onlyFirst();
    final errors = <Object>[];
    final failing = _ThrowingNotifier();
    final s = SchedulerService(
      data,
      clock: Clock(() => now),
      notifier: failing,
      onError: (e, _) => errors.add(e),
    );
    await data.settings.update((x) => x.copyWith(buddyVisible: false));
    await s.start(autoTick: false);
    await settle();
    now = now.add(const Duration(hours: 1));
    await s.tick();
    await settle();
    expect(errors, isNotEmpty, reason: 'notification refused');
    await s.respond(LogAction.done);
    await settle();
    // Later effects still ran: the response was logged and rescheduled.
    expect((await data.log.since(0)).single.action, LogAction.done);
    await s.dispose();
  });

  test('after dispose nothing more is dispatched', () async {
    await onlyFirst();
    await service.start(autoTick: false);
    await settle();
    await service.dispose();
    now = now.add(const Duration(hours: 1));
    await service.tick();
    await service.respond(LogAction.done);
    expect(await data.log.since(0), isEmpty);
  });

  test('upcoming lists enabled reminders soonest first', () async {
    await service.start(autoTick: false);
    await settle();
    // From 10:00: stretch +45 → 10:45, water +60 → 11:00, meeting 19:00.
    expect(service.upcoming().map((r) => r.title), [
      'Stretch break',
      'Drink water',
      'Evening meeting',
    ]);
    final times = service.upcoming().map((r) => r.nextDueAt!).toList();
    expect(wc.toWall(times.first).minuteOfDay, 10 * 60 + 45);
    expect(wc.toWall(times.last).hour, 19);
  });
}

class _ThrowingNotifier implements AlertNotifier {
  @override
  Future<void> show(
    AlertView alert, {
    required void Function() onDone,
    required void Function() onSkip,
    required void Function() onSnooze,
  }) async => throw StateError('notifications are off');

  @override
  Future<void> dismiss() async {}
}
