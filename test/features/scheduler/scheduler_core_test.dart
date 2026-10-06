import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/scheduler_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tz_wall_clock.dart';

final ny = TzWallClock('America/New_York');
const int min = Duration.millisecondsPerMinute;
const int sec = Duration.millisecondsPerSecond;

/// Tue 2026-10-06 12:00 New York.
final int t0 = ny.at(2026, 10, 6, 12);

Reminder rem(
  String id, {
  int? due,
  ScheduleType type = ScheduleType.interval,
  int every = 60,
  String? from,
  String? to,
  String? date,
  String time = '09:00',
  bool enabled = true,
  int createdAt = 0,
  int updatedAt = 0,
}) => Reminder(
  id: id,
  title: id,
  categoryId: 'cat-$id',
  createdAt: createdAt,
  updatedAt: updatedAt,
  scheduleType: type,
  everyMinutes: every,
  activeFrom: from,
  activeTo: to,
  date: date,
  timeOfDay: time,
  enabled: enabled,
  nextDueAt: due,
);

/// Drives a core and keeps a simulated database in sync with its effects.
class Harness {
  Harness(List<Reminder> reminders, {SchedulerConfig? config}) {
    for (final r in reminders) {
      db[r.id] = r;
    }
    if (config != null) core.handle(ConfigChanged(config, t0));
    reload();
  }

  final core = SchedulerCore(wallClock: ny);
  final db = <String, Reminder>{};
  final logs = <WriteLog>[];
  final shown = <String>[];

  List<SchedulerEffect> send(SchedulerEvent e) {
    final fx = core.handle(e);
    for (final f in fx) {
      switch (f) {
        case WriteLog():
          logs.add(f);
        case UpdateSchedule():
          final r = db[f.reminderId]!;
          db[f.reminderId] = r.copyWith(
            nextDueAt: f.nextDueAt,
            enabled: f.enabled ?? r.enabled,
          );
        case ShowAlert():
          shown.add(f.test ? 'test:${f.reminder.id}' : f.reminder.id);
        case HideAlert():
          break;
      }
    }
    return fx;
  }

  List<SchedulerEffect> reload([int? now]) =>
      send(RemindersLoaded(db.values.toList(), now ?? t0));

  List<SchedulerEffect> tick(int now) => send(Tick(now));

  /// Ticks every second from [from] to [to] inclusive.
  void run(int from, int to) {
    for (var t = from; t <= to; t += sec) {
      tick(t);
    }
  }

  String? get alertId => core.alert?.reminderId;
}

void main() {
  group('firing', () {
    test('nothing before due, fires at due', () {
      final h = Harness([rem('a', due: t0 + 5 * sec)]);
      h.run(t0, t0 + 4 * sec);
      expect(h.alertId, isNull);
      h.tick(t0 + 5 * sec);
      expect(h.alertId, 'a');
      expect(h.shown, ['a']);
    });

    test('disabled reminders never fire', () {
      final h = Harness([rem('a', due: t0, enabled: false)]);
      h.tick(t0);
      expect(h.alertId, isNull);
    });

    test('one pop-up at a time; earliest first; the rest queue', () {
      final h = Harness([
        rem('late', due: t0 - 1 * min),
        rem('early', due: t0 - 5 * min),
        rem('mid', due: t0 - 3 * min),
      ]);
      h.run(t0, t0 + 10 * sec);
      expect(h.shown, ['early']);
      h.send(Respond(LogAction.done, t0 + 11 * sec));
      h.tick(t0 + 12 * sec);
      expect(h.alertId, 'mid');
      h.send(Respond(LogAction.done, t0 + 13 * sec));
      h.tick(t0 + 14 * sec);
      expect(h.shown, ['early', 'mid', 'late']);
    });

    test('ties break by creation order', () {
      final h = Harness([
        rem('b', due: t0, createdAt: 2),
        rem('a', due: t0, createdAt: 1),
      ]);
      h.tick(t0);
      expect(h.alertId, 'a');
    });
  });

  group('responses', () {
    test('done: logs with response time, next from now', () {
      final h = Harness([rem('a', due: t0)]);
      h.tick(t0);
      h.send(Respond(LogAction.done, t0 + 42 * sec));
      expect(h.logs.single.action, LogAction.done);
      expect(h.logs.single.responseSeconds, 42);
      expect(h.logs.single.categoryId, 'cat-a');
      expect(h.db['a']!.nextDueAt, t0 + 42 * sec + 60 * min);
      expect(h.alertId, isNull);
    });

    test('snoozed: now + snooze minutes', () {
      final h = Harness(
        [rem('a', due: t0)],
        config: const SchedulerConfig(snoozeMinutes: 15),
      );
      h.tick(t0);
      h.send(Respond(LogAction.snoozed, t0 + 3 * sec));
      expect(h.logs.single.action, LogAction.snoozed);
      expect(h.db['a']!.nextDueAt, t0 + 3 * sec + 15 * min);
      expect(h.db['a']!.enabled, isTrue);
    });

    test('"No" (skipped): logged as skipped, next normal time', () {
      final h = Harness([rem('a', due: t0)]);
      h.tick(t0);
      h.send(Respond(LogAction.skipped, t0 + 4 * sec));
      expect(h.logs.single.action, LogAction.skipped);
      expect(h.logs.single.responseSeconds, 4);
      // Not a snooze: back on its interval from now.
      expect(h.db['a']!.nextDueAt, t0 + 4 * sec + 60 * min);
      expect(h.alertId, isNull);
    });

    test('a skipped one-off switches itself off', () {
      final h = Harness([
        rem('o', type: ScheduleType.once, date: '2026-10-06', time: '12:05'),
      ]);
      final at = ny.at(2026, 10, 6, 12, 5);
      h.tick(at);
      h.send(Respond(LogAction.skipped, at + sec));
      expect(h.db['o']!.enabled, isFalse);
    });

    test('auto-miss after autoMissMinutes, then next from now', () {
      final h = Harness(
        [rem('a', due: t0)],
        config: const SchedulerConfig(autoMissMinutes: 2),
      );
      h.tick(t0);
      h.run(t0 + sec, t0 + 2 * min - sec);
      expect(h.logs, isEmpty);
      h.tick(t0 + 2 * min);
      expect(h.logs.single.action, LogAction.missed);
      expect(h.logs.single.responseSeconds, 120);
      expect(h.db['a']!.nextDueAt, t0 + 2 * min + 60 * min);
    });

    test('a one-off disables itself after it fires', () {
      final h = Harness([
        rem('o', type: ScheduleType.once, date: '2026-10-06', time: '12:00'),
      ]);
      // Loading schedules it for 12:00 today… but t0 IS 12:00 → passed.
      expect(h.db['o']!.enabled, isFalse);

      final h2 = Harness([
        rem('o', type: ScheduleType.once, date: '2026-10-06', time: '12:05'),
      ]);
      expect(h2.db['o']!.nextDueAt, ny.at(2026, 10, 6, 12, 5));
      h2.tick(ny.at(2026, 10, 6, 12, 5));
      h2.send(Respond(LogAction.done, ny.at(2026, 10, 6, 12, 6)));
      expect(h2.db['o']!.enabled, isFalse);
      expect(h2.db['o']!.nextDueAt, isNull);
    });

    test('a snoozed one-off stays enabled and comes back', () {
      final h = Harness([
        rem('o', type: ScheduleType.once, date: '2026-10-06', time: '12:05'),
      ]);
      final at = ny.at(2026, 10, 6, 12, 5);
      h.tick(at);
      h.send(Respond(LogAction.snoozed, at));
      expect(h.db['o']!.enabled, isTrue);
      h.tick(at + 10 * min);
      expect(h.alertId, 'o');
    });

    test('responding with nothing open does nothing', () {
      final h = Harness([rem('a', due: t0 + min)]);
      expect(h.send(Respond(LogAction.done, t0)), isEmpty);
    });
  });

  group('do not disturb', () {
    test('fires nothing while on; overdue fire one at a time after', () {
      final h = Harness(
        [rem('a', due: t0 + min), rem('b', due: t0 + 2 * min)],
        config: const SchedulerConfig(doNotDisturb: true),
      );
      h.run(t0, t0 + 5 * min);
      expect(h.shown, isEmpty);
      h.send(ConfigChanged(const SchedulerConfig(), t0 + 5 * min));
      h.tick(t0 + 5 * min + sec);
      expect(h.shown, ['a']);
      h.tick(t0 + 5 * min + 2 * sec);
      expect(h.shown, ['a'], reason: 'b waits for a response');
      h.send(Respond(LogAction.done, t0 + 6 * min));
      h.tick(t0 + 6 * min + sec);
      expect(h.shown, ['a', 'b']);
    });

    test('turning it on hides an open pop-up without logging; it returns', () {
      final h = Harness([rem('a', due: t0)]);
      h.tick(t0);
      final fx = h.send(
        ConfigChanged(const SchedulerConfig(doNotDisturb: true), t0 + sec),
      );
      expect(fx.whereType<HideAlert>(), hasLength(1));
      expect(h.logs, isEmpty);
      expect(h.db['a']!.nextDueAt, t0, reason: 'still due');
      h.send(ConfigChanged(const SchedulerConfig(), t0 + min));
      h.tick(t0 + min + sec);
      expect(h.shown, ['a', 'a']);
    });
  });

  group('sleep and long gaps', () {
    test('each overdue reminder fires once, then reschedules from now', () {
      // Every 10 min; asleep for 3 hours → 18 missed slots, one pop-up.
      final h = Harness([rem('a', every: 10, due: t0 + 10 * min)]);
      h.tick(t0);
      final wake = t0 + 3 * 60 * min;
      h.tick(wake);
      expect(h.core.lastTickWasGap, isTrue);
      expect(h.shown, ['a']);
      h.send(Respond(LogAction.done, wake + 5 * sec));
      expect(h.db['a']!.nextDueAt, wake + 5 * sec + 10 * min);
      h.run(wake + 6 * sec, wake + 9 * min);
      expect(h.shown, ['a'], reason: 'no backlog replay');
    });

    test('several overdue reminders: one each, in due order', () {
      final h = Harness([
        rem('x', due: t0 + 30 * min),
        rem('y', due: t0 + 10 * min),
      ]);
      h.tick(t0);
      final wake = t0 + 120 * min;
      h.tick(wake);
      h.send(Respond(LogAction.done, wake + sec));
      h.tick(wake + 2 * sec);
      h.send(Respond(LogAction.done, wake + 3 * sec));
      h.run(wake + 4 * sec, wake + 30 * sec);
      expect(h.shown, ['y', 'x']);
    });

    test('a pop-up left open over sleep is missed on wake', () {
      final h = Harness(
        [rem('a', due: t0)],
        config: const SchedulerConfig(),
      );
      h.tick(t0);
      h.tick(t0 + sec);
      h.tick(t0 + 90 * min); // woke up
      expect(h.logs.single.action, LogAction.missed);
      // It was last seen at the tick before sleep: that's when it counts.
      expect(h.logs.single.responseSeconds, 1);
      expect(h.logs.single.at, t0 + sec);
    });

    test('an interval due inside its window is skipped if the window closed '
        'while asleep', () {
      // Due at 21:30 (window 08–22); wakes at 23:00.
      final due = ny.at(2026, 10, 6, 21, 30);
      final h = Harness([
        rem('a', due: due, from: '08:00', to: '22:00'),
      ]);
      h.tick(ny.at(2026, 10, 6, 21));
      h.tick(ny.at(2026, 10, 6, 23));
      expect(h.shown, isEmpty);
      expect(ny.show(h.db['a']!.nextDueAt), '2026-10-07 08:00');
    });
  });

  group('active windows only skip after sleep', () {
    // Window 08–22; it's 21:59 and the reminder is due now.
    final late = ny.at(2026, 10, 6, 21, 59);

    test('a reminder queued behind another fires after the window end', () {
      final h = Harness([
        rem('other', due: late - min),
        rem('a', due: late, from: '08:00', to: '22:00'),
      ]);
      // Ticks every second, as in the app (a jump would look like sleep).
      final answered = ny.at(2026, 10, 6, 22, 1);
      h.run(late, answered);
      h.send(Respond(LogAction.done, answered));
      h.run(answered + sec, answered + 2 * sec);
      expect(h.shown, ['other', 'a']);
    });

    test('a snooze past the window end still comes back', () {
      final h = Harness(
        [rem('a', due: ny.at(2026, 10, 6, 21, 55), from: '08:00', to: '22:00')],
      );
      h.tick(ny.at(2026, 10, 6, 21, 55));
      h.send(Respond(LogAction.snoozed, ny.at(2026, 10, 6, 21, 55)));
      h.run(ny.at(2026, 10, 6, 21, 55) + sec, ny.at(2026, 10, 6, 22, 5) + sec);
      expect(h.shown, ['a', 'a']);
    });

    test('DND ending after the window still fires what was due', () {
      final h = Harness(
        [rem('a', due: late, from: '08:00', to: '22:00')],
        config: const SchedulerConfig(doNotDisturb: true),
      );
      final after = ny.at(2026, 10, 6, 22, 30);
      h.run(late, after);
      h.send(ConfigChanged(const SchedulerConfig(), after));
      h.tick(after + sec);
      expect(h.shown, ['a']);
    });
  });

  group('responses target a specific pop-up', () {
    test('a stale click (older firedAt) is ignored', () {
      final h = Harness([rem('a', due: t0), rem('b', due: t0)]);
      h.tick(t0); // a fires
      final aFired = h.core.alert!.firedAt;
      h.send(Respond(LogAction.done, t0 + sec, firedAt: aFired));
      h.tick(t0 + 2 * sec); // b fires
      // A late second click meant for a must not answer b.
      h.send(Respond(LogAction.done, t0 + 3 * sec, firedAt: aFired));
      expect(h.alertId, 'b');
      expect(h.logs, hasLength(1));
    });
  });

  group('test fire', () {
    test('a test pop-up of a disabled reminder survives reloads', () {
      final h = Harness([rem('off', enabled: false), rem('x', due: t0 + min)]);
      h.send(TestFire('off', t0));
      h.reload(t0 + sec);
      expect(h.alertId, 'off');
    });

    test('is not logged and does not reschedule', () {
      final h = Harness([rem('a', due: t0 + 30 * min)]);
      h.send(TestFire('a', t0));
      expect(h.shown, ['test:a']);
      h.send(Respond(LogAction.done, t0 + sec));
      expect(h.logs, isEmpty);
      expect(h.db['a']!.nextDueAt, t0 + 30 * min);
    });

    test('works during DND and auto-closes silently', () {
      final h = Harness(
        [rem('a', due: t0 + 30 * min)],
        config: const SchedulerConfig(doNotDisturb: true, autoMissMinutes: 2),
      );
      h.send(TestFire('a', t0));
      expect(h.alertId, 'a');
      h.tick(t0 + 2 * min);
      expect(h.alertId, isNull);
      expect(h.logs, isEmpty);
    });

    test('replacing a real pop-up leaves the real one due', () {
      final h = Harness([rem('a', due: t0), rem('b', due: t0 + 60 * min)]);
      h.tick(t0);
      h.send(TestFire('b', t0 + sec));
      expect(h.logs, isEmpty);
      h.send(Respond(LogAction.done, t0 + 2 * sec)); // closes the test
      h.tick(t0 + 3 * sec);
      expect(h.shown, ['a', 'test:b', 'a']);
    });
  });

  group('snooze all', () {
    test('pushes everything due within the window; logs an open pop-up', () {
      final h = Harness([
        rem('open', due: t0),
        rem('soon', due: t0 + 10 * min),
        rem('later', due: t0 + 60 * min),
      ]);
      h.tick(t0);
      h.send(SnoozeAll(30, t0 + sec));
      final until = t0 + sec + 30 * min;
      expect(h.logs.single.action, LogAction.snoozed);
      expect(h.db['open']!.nextDueAt, until);
      expect(h.db['soon']!.nextDueAt, until);
      expect(h.db['later']!.nextDueAt, t0 + 60 * min);
    });
  });

  group('reloads', () {
    test('enabled reminders without a due time get one (seeded)', () {
      final h = Harness([rem('a', every: 45)]);
      expect(h.db['a']!.nextDueAt, t0 + 45 * min);
    });

    test('a stale reload cannot make a reminder fire twice', () {
      final h = Harness([rem('a', due: t0)]);
      final stale = h.db.values.toList();
      h.tick(t0);
      h.send(Respond(LogAction.done, t0 + sec));
      // A query result from before our write arrives late.
      h.send(RemindersLoaded(stale, t0 + 2 * sec));
      h.tick(t0 + 3 * sec);
      expect(h.shown, ['a']);
      expect(h.core.upcoming().single.nextDueAt, t0 + sec + 60 * min);
    });

    test('an edit from the other window wins over our pending write', () {
      final h = Harness([rem('a', due: t0)]);
      h.tick(t0);
      h.send(Respond(LogAction.done, t0 + sec));
      // Dashboard edited the reminder (newer updatedAt) with a new due time.
      h.db['a'] = h.db['a']!.copyWith(updatedAt: 99, nextDueAt: t0 + 5 * sec);
      h.reload(t0 + 2 * sec);
      h.tick(t0 + 5 * sec);
      expect(h.shown, ['a', 'a']);
    });

    test('deleting or disabling the open reminder closes it, no log', () {
      final h = Harness([rem('a', due: t0)]);
      h.tick(t0);
      h.db.remove('a');
      final fx = h.reload(t0 + sec);
      expect(fx.whereType<HideAlert>(), hasLength(1));
      expect(h.logs, isEmpty);
      expect(h.alertId, isNull);
    });
  });
}
