import 'package:clock/clock.dart';
import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/features/reminders/application/reminder_commands.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/shared/format/countdown.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  late AppData data;
  late ReminderCommands commands;
  late String cat;

  setUp(() async {
    data = await memoryData();
    commands = ReminderCommands(
      data.reminders,
      data.log,
      clock: Clock.fixed(testNow), // Tue 2026-10-06 10:00
    );
    cat = (await data.categories.create(name: 'A')).id;
  });
  tearDown(() => data.close());

  Reminder r() => commands.blank(categoryId: cat).copyWith(title: 'Call');

  group('validate (editor messages)', () {
    test('title required', () {
      expect(
        commands.validate(r().copyWith(title: '  '))?.message,
        'Give the reminder a title',
      );
    });

    test('one-off needs a date', () {
      expect(
        commands
            .validate(r().copyWith(scheduleType: ScheduleType.once))
            ?.message,
        'Pick a date for a one-time reminder',
      );
    });

    test('one-off in the past', () {
      final past = r().copyWith(
        scheduleType: ScheduleType.once,
        date: '2026-10-06',
        timeOfDay: '09:59',
      );
      expect(commands.validate(past)?.message, 'That time has already passed');
      expect(
        commands.validate(past.copyWith(timeOfDay: '10:01')),
        isNull,
      );
    });

    test('interval below 1 minute is rejected', () {
      expect(
        commands.validate(r().copyWith(everyMinutes: 0))?.message,
        'Repeat every 1 minute or more',
      );
    });

    test('a disabled one-off in the past can still be saved (rename)', () {
      final fired = r().copyWith(
        scheduleType: ScheduleType.once,
        date: '2026-10-01',
        timeOfDay: '09:00',
        enabled: false,
      );
      expect(commands.validate(fired), isNull);
    });

    test('a valid reminder has no problem', () {
      expect(commands.validate(r()), isNull);
    });
  });

  group('save', () {
    test('schedules from now and tidies fields', () async {
      final saved = await commands.save(
        r().copyWith(title: ' Call ', everyMinutes: 1, dailyGoal: -2),
      );
      expect(saved.title, 'Call');
      expect(saved.dailyGoal, 0);
      expect(
        saved.nextDueAt,
        testNow.add(const Duration(minutes: 1)).millisecondsSinceEpoch,
      );
    });

    test('a disabled reminder saves unscheduled', () async {
      final saved = await commands.save(r().copyWith(enabled: false));
      expect(saved.nextDueAt, isNull);
    });

    test('rejects an invalid reminder', () {
      expect(
        () => commands.save(r().copyWith(title: '')),
        throwsArgumentError,
      );
    });

    test('a new reminder starts with the greeting template', () {
      expect(commands.blank(categoryId: cat).messageTemplate, 'Hey, {name}! ');
    });
  });

  test('setEnabled recomputes from now (and clears when off)', () async {
    final saved = await commands.save(r());
    await commands.setEnabled(saved.id, enabled: false);
    final off = (await data.reminders.byId(saved.id))!;
    expect((off.enabled, off.nextDueAt), (false, null));
    await commands.setEnabled(saved.id, enabled: true);
    final on = (await data.reminders.byId(saved.id))!;
    expect(on.enabled, isTrue);
    expect(on.nextDueAt, isNotNull);
  });

  test('a past one-off cannot be switched back on', () async {
    final once = await data.reminders.save(
      r().copyWith(
        scheduleType: ScheduleType.once,
        date: '2026-10-01',
        timeOfDay: '09:00',
        enabled: false,
      ),
    );
    await commands.setEnabled(once.id, enabled: true);
    expect((await data.reminders.byId(once.id))!.enabled, isFalse);
  });

  test('logManual writes a manual done entry', () async {
    final saved = await commands.save(r());
    await commands.logManual(saved);
    final e = (await data.log.since(0)).single;
    expect(
      (e.action, e.manual, e.reminderId),
      (LogAction.done, true, saved.id),
    );
    expect(e.categoryId, cat);
  });

  group('formatCountdown (prototype fmtIn)', () {
    const s = 1000;
    test('every range', () {
      expect(formatCountdown(0), 'now');
      expect(formatCountdown(-5), 'now');
      expect(formatCountdown(45 * s), '45s');
      expect(formatCountdown(59 * s), '59s');
      expect(formatCountdown(60 * s), '1 min');
      expect(formatCountdown(59 * 60 * s), '59 min');
      expect(formatCountdown((3 * 60 + 5) * 60 * s), '3h 5m');
      expect(formatCountdown(49 * 3600 * s), '2d');
    });
  });
}
