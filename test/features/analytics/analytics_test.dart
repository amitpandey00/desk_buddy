import 'dart:math';

import 'package:desk_buddy/features/analytics/domain/sample_history.dart';
import 'package:desk_buddy/features/analytics/domain/week_analytics.dart';
import 'package:desk_buddy/features/categories/domain/category.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/shared/format/schedule_describe.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tz_wall_clock.dart';

void main() {
  final ny = TzWallClock('America/New_York');
  final now = ny.at(2026, 10, 6, 15); // Tue
  var n = 0;
  LogEntry e(
    int at, {
    LogAction a = LogAction.done,
    String rid = 'r1',
    String? cat = 'c1',
    bool manual = false,
    int rt = 10,
  }) => LogEntry(
    id: '${n++}',
    at: at,
    action: a,
    reminderId: rid,
    categoryId: cat,
    manual: manual,
    responseSeconds: rt,
  );
  Reminder r(String id, {int goal = 0}) => Reminder(
    id: id,
    title: id,
    categoryId: 'c1',
    createdAt: 0,
    updatedAt: 0,
    dailyGoal: goal,
  );
  const cats = [
    Category(id: 'c1', name: 'A', emoji: 'a', colorHex: '#000000'),
    Category(id: 'c2', name: 'B', emoji: 'b', colorHex: '#FFFFFF'),
  ];

  group('WeekAnalytics', () {
    late WeekAnalytics a;
    setUp(() {
      a = WeekAnalytics.compute(
        reminders: [r('r1'), r('r2')],
        categories: cats,
        now: now,
        wallClock: ny,
        log: [
          e(ny.at(2026, 9, 29, 12)), // 7 days ago: outside the week
          e(ny.at(2026, 9, 30, 9), rt: 20), // first day of the week
          e(ny.at(2026, 10, 6, 9), rt: 40),
          e(ny.at(2026, 10, 6, 9), manual: true, rt: 0),
          e(ny.at(2026, 10, 6, 10), a: LogAction.snoozed, rid: 'r2'),
          e(ny.at(2026, 10, 6, 11), a: LogAction.missed),
          e(ny.at(2026, 10, 5, 9), cat: 'gone'), // deleted category
          e(ny.at(2026, 10, 6, 12), a: LogAction.skipped, rid: 'r2'),
        ],
      );
    });

    test('7 local days ending today', () {
      expect(a.dayStarts, hasLength(7));
      expect(ny.show(a.dayStarts.first), '2026-09-30 00:00');
      expect(ny.show(a.dayStarts.last), '2026-10-06 00:00');
    });

    test('KPIs: manual entries count as done but not toward the rate', () {
      expect((a.done, a.snoozed, a.missed, a.skipped), (4, 1, 1, 1));
      // Pop-up responses: 3 done (9/30, 10/6, 10/5) + snoozed + missed
      // + skipped ("No" counts against the rate).
      expect(a.completionPercent, 50);
      expect(a.averageResponseSeconds, ((20 + 40 + 10) / 3).round());
    });

    test('per day by category; deleted categories become "Other"', () {
      expect(a.completedPerDay.first, {'c1': 1});
      expect(a.completedPerDay[5], {null: 1});
      expect(a.completedPerDay[6], {'c1': 2});
      expect(a.usedCategoryKeys, {'c1', null});
      expect(a.maxCompletedInADay, 2);
    });

    test('by hour', () {
      expect(a.completedByHour[9], 4);
      expect(a.completedByHour.reduce((x, y) => x + y), 4);
    });

    test('by reminder excludes manual entries', () {
      final r1 = a.perReminder.first;
      expect((r1.done, r1.snoozed, r1.missed), (3, 0, 1));
      expect(r1.completionPercent, 75);
      final r2 = a.perReminder.last;
      expect((r2.snoozed, r2.skipped), (1, 1));
      expect(r2.completionPercent, 0);
    });

    test('empty week', () {
      final empty = WeekAnalytics.compute(
        reminders: const [],
        categories: cats,
        log: const [],
        now: now,
        wallClock: ny,
      );
      expect(empty.isEmpty, isTrue);
      expect(empty.completionPercent, 0);
      expect(empty.perReminder, isEmpty);
    });
  });

  test('goalSeries counts done per day incl. manual', () {
    final days = [for (var i = -6; i <= 0; i++) ny.startOfDayOffset(now, i)];
    final series = goalSeries(
      r('r1', goal: 2),
      [
        e(ny.at(2026, 10, 6, 9)),
        e(ny.at(2026, 10, 6, 10), manual: true),
        e(ny.at(2026, 10, 4, 9)),
        e(ny.at(2026, 10, 4, 9), a: LogAction.missed),
      ],
      days,
      ny,
    );
    expect(series, [0, 0, 0, 0, 1, 0, 2]);
  });

  test('sample history follows each schedule and is flagged', () {
    final out = generateSampleHistory(
      reminders: [
        const Reminder(
          id: 'i',
          title: 'i',
          categoryId: 'c',
          createdAt: 0,
          updatedAt: 0,
          activeFrom: '08:00',
          activeTo: '12:00',
        ),
        const Reminder(
          id: 'd',
          title: 'd',
          categoryId: 'c',
          createdAt: 0,
          updatedAt: 0,
          scheduleType: ScheduleType.daily,
          timeOfDay: '19:00',
          daysOfWeek: [1], // Mondays
        ),
      ],
      now: now,
      wallClock: ny,
      newId: () => '${n++}',
      random: Random(1),
    );
    // 6 days × 4 interval slots (09,10,11,12) + one Monday.
    expect(out.where((l) => l.reminderId == 'i'), hasLength(24));
    expect(out.where((l) => l.reminderId == 'd'), hasLength(1));
    expect(out.every((l) => l.sample && !l.manual), isTrue);
    expect(out.every((l) => l.at < ny.startOfDay(now)), isTrue);
  });

  group('describeSchedule (prototype describe())', () {
    Reminder base(ScheduleType t) => Reminder(
      id: 'x',
      title: 'x',
      categoryId: 'c',
      createdAt: 0,
      updatedAt: 0,
      scheduleType: t,
    );

    test('interval', () {
      expect(
        describeSchedule(
          base(ScheduleType.interval).copyWith(
            everyMinutes: 60,
            activeFrom: '08:00',
            activeTo: '22:00',
          ),
        ),
        'Every 60 min, 08:00–22:00',
      );
      expect(describeSchedule(base(ScheduleType.interval)), 'Every 60 min');
    });

    test('daily', () {
      final d = base(ScheduleType.daily).copyWith(timeOfDay: '19:00');
      expect(describeSchedule(d), '7:00 PM, every day');
      expect(
        describeSchedule(d.copyWith(daysOfWeek: [5, 1, 2, 3, 4])),
        '7:00 PM, weekdays',
      );
      expect(
        describeSchedule(d.copyWith(daysOfWeek: [0, 6])),
        '7:00 PM, weekends',
      );
      expect(
        describeSchedule(d.copyWith(daysOfWeek: [1, 3, 5])),
        '7:00 PM, Mon, Wed, Fri',
      );
      expect(
        describeSchedule(d.copyWith(daysOfWeek: [0, 1, 2, 3, 4, 5, 6])),
        '7:00 PM, every day',
      );
    });

    test('once', () {
      expect(
        describeSchedule(
          base(ScheduleType.once).copyWith(date: '2026-10-10'),
        ),
        'Once on 2026-10-10 at 9:00 AM',
      );
    });

    test('12-hour format edges', () {
      expect(format12h('00:05'), '12:05 AM');
      expect(format12h('12:00'), '12:00 PM');
      expect(format12h('23:59'), '11:59 PM');
    });
  });
}
