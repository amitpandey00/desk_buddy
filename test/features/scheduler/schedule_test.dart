import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/schedule.dart';
import 'package:desk_buddy/features/scheduler/engine/wall_clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tz_wall_clock.dart';

Reminder interval(int every, [String? from, String? to]) => Reminder(
  id: 'i',
  title: 'i',
  categoryId: 'c',
  createdAt: 0,
  updatedAt: 0,
  everyMinutes: every,
  activeFrom: from,
  activeTo: to,
);

Reminder daily(String time, [List<int> days = const []]) => Reminder(
  id: 'd',
  title: 'd',
  categoryId: 'c',
  createdAt: 0,
  updatedAt: 0,
  scheduleType: ScheduleType.daily,
  timeOfDay: time,
  daysOfWeek: days,
);

Reminder once(String? date, String time) => Reminder(
  id: 'o',
  title: 'o',
  categoryId: 'c',
  createdAt: 0,
  updatedAt: 0,
  scheduleType: ScheduleType.once,
  date: date,
  timeOfDay: time,
);

void main() {
  final ny = TzWallClock('America/New_York');
  String next(Reminder r, int from, [WallClock? wc]) =>
      ny.show(computeNext(r, from, wc ?? ny));

  group('parsing', () {
    test('HH:mm', () {
      expect(parseHm('08:05'), 485);
      expect(parseHm('8:05'), 485);
      expect(parseHm('23:59'), 1439);
      expect(parseHm('24:00'), isNull);
      expect(parseHm('7pm'), isNull);
      expect(parseHm(null), isNull);
    });
    test('yyyy-MM-dd', () {
      expect(parseDate('2026-10-10'), (2026, 10, 10));
      expect(parseDate('10/10/2026'), isNull);
    });
  });

  group('interval', () {
    // Tue 2026-10-06
    test('no window: from + every', () {
      expect(
        next(interval(45), ny.at(2026, 10, 6, 23, 50)),
        '2026-10-07 00:35',
      );
    });

    test('inside the window', () {
      final r = interval(60, '08:00', '22:00');
      expect(next(r, ny.at(2026, 10, 6, 9, 15)), '2026-10-06 10:15');
    });

    test('window end is inclusive', () {
      final r = interval(60, '08:00', '22:00');
      expect(next(r, ny.at(2026, 10, 6, 21)), '2026-10-06 22:00');
    });

    test('before the window → that day’s start', () {
      final r = interval(60, '08:00', '22:00');
      expect(next(r, ny.at(2026, 10, 6, 5)), '2026-10-06 08:00');
    });

    test('after the window → next day’s start', () {
      final r = interval(60, '08:00', '22:00');
      expect(next(r, ny.at(2026, 10, 6, 21, 30)), '2026-10-07 08:00');
    });

    test('overnight window 22:00–02:00', () {
      final r = interval(60, '22:00', '02:00');
      // Late evening, inside.
      expect(next(r, ny.at(2026, 10, 6, 22, 30)), '2026-10-06 23:30');
      // Crosses midnight, still inside.
      expect(next(r, ny.at(2026, 10, 6, 23, 30)), '2026-10-07 00:30');
      // Lands at 02:30: in the daytime gap → that evening.
      expect(next(r, ny.at(2026, 10, 7, 1, 30)), '2026-10-07 22:00');
      // Daytime → this evening.
      expect(next(r, ny.at(2026, 10, 7, 12)), '2026-10-07 22:00');
    });

    test('every < 1 is treated as 1 minute', () {
      expect(next(interval(0), ny.at(2026, 10, 6, 9)), '2026-10-06 09:01');
    });

    test('intervals are elapsed time across DST (spring forward)', () {
      // 01:30 EST + 60 min = 03:30 EDT (02:xx doesn't exist).
      expect(next(interval(60), ny.at(2026, 3, 8, 1, 30)), '2026-03-08 03:30');
    });

    test('window start on a DST day stays at wall-clock 08:00', () {
      final r = interval(60, '08:00', '22:00');
      expect(next(r, ny.at(2026, 3, 7, 21, 30)), '2026-03-08 08:00');
      expect(next(r, ny.at(2026, 10, 31, 21, 30)), '2026-11-01 08:00');
    });
  });

  group('daily', () {
    test('later today when the time is still ahead', () {
      expect(next(daily('19:00'), ny.at(2026, 10, 6, 10)), '2026-10-06 19:00');
    });

    test('same minute is not "after": goes to tomorrow', () {
      expect(next(daily('19:00'), ny.at(2026, 10, 6, 19)), '2026-10-07 19:00');
    });

    test('a second past the minute also goes to tomorrow', () {
      final from = ny.at(2026, 10, 6, 19) + 1000;
      expect(next(daily('19:00'), from), '2026-10-07 19:00');
    });

    test('specific weekdays skip ahead (Fri evening → Mon)', () {
      // 2026-10-09 is a Friday.
      final r = daily('19:00', [1, 2, 3, 4, 5]);
      expect(next(r, ny.at(2026, 10, 9, 20)), '2026-10-12 19:00');
    });

    test('a single weekday a full week away is found', () {
      // Tue → next Tue.
      expect(
        next(daily('09:00', [2]), ny.at(2026, 10, 6, 10)),
        '2026-10-13 09:00',
      );
    });

    test('invalid weekdays mean never', () {
      expect(computeNext(daily('09:00', [9]), ny.at(2026, 10, 6), ny), isNull);
    });

    test('07:00 stays 07:00 across spring forward and fall back', () {
      final r = daily('07:00');
      expect(next(r, ny.at(2026, 3, 7, 8)), '2026-03-08 07:00');
      expect(next(r, ny.at(2026, 3, 8, 8)), '2026-03-09 07:00');
      expect(next(r, ny.at(2026, 10, 31, 8)), '2026-11-01 07:00');
      // 23 h and 25 h apart in real time, both exactly 07:00 local.
      final spring = computeNext(r, ny.at(2026, 3, 7, 8), ny)!;
      expect(spring - ny.at(2026, 3, 7, 7), Duration.millisecondsPerHour * 23);
      final fall = computeNext(r, ny.at(2026, 10, 31, 8), ny)!;
      expect(fall - ny.at(2026, 10, 31, 7), Duration.millisecondsPerHour * 25);
    });

    test('a time inside the spring gap fires just after it', () {
      expect(next(daily('02:30'), ny.at(2026, 3, 7, 12)), '2026-03-08 03:30');
      expect(next(daily('02:30'), ny.at(2026, 3, 8, 12)), '2026-03-09 02:30');
    });

    test('a repeated time on fall-back day fires once (the first one)', () {
      final r = daily('01:30');
      final first = computeNext(r, ny.at(2026, 10, 31, 12), ny)!;
      expect(ny.show(first), '2026-11-01 01:30');
      // Asking again right after it must give tomorrow, not the repeat.
      expect(next(r, first), '2026-11-02 01:30');
    });

    test('works in a southern-hemisphere zone too', () {
      final syd = TzWallClock('Australia/Sydney');
      // Sydney springs forward 2026-10-04.
      final from = syd.at(2026, 10, 3, 12);
      expect(
        syd.show(computeNext(daily('07:00'), from, syd)),
        '2026-10-04 07:00',
      );
    });
  });

  group('once', () {
    test('future → that moment', () {
      expect(
        next(once('2026-10-10', '09:00'), ny.at(2026, 10, 6)),
        '2026-10-10 09:00',
      );
    });

    test('past or now → null', () {
      final at = ny.at(2026, 10, 10, 9);
      expect(computeNext(once('2026-10-10', '09:00'), at, ny), isNull);
      expect(computeNext(once('2026-10-01', '09:00'), at, ny), isNull);
    });

    test('missing or malformed date → null', () {
      expect(computeNext(once(null, '09:00'), 0, ny), isNull);
      expect(computeNext(once('soon', '09:00'), 0, ny), isNull);
    });
  });

  group('mayFireAt', () {
    test('only interval reminders outside their window are held', () {
      final r = interval(60, '08:00', '22:00');
      expect(mayFireAt(r, ny.at(2026, 10, 6, 12), ny), isTrue);
      expect(mayFireAt(r, ny.at(2026, 10, 6, 23), ny), isFalse);
      expect(mayFireAt(interval(60), ny.at(2026, 10, 6, 23), ny), isTrue);
      expect(mayFireAt(daily('19:00'), ny.at(2026, 10, 6, 23), ny), isTrue);
    });
  });

  group('WallClock', () {
    test('day overflow rolls into the next month', () {
      expect(ny.show(ny.at(2026, 1, 32, 7)), '2026-02-01 07:00');
    });

    test('startOfDay / offset are calendar days, not 24 h', () {
      final noon = ny.at(2026, 3, 8, 12);
      expect(ny.show(ny.startOfDay(noon)), '2026-03-08 00:00');
      expect(ny.show(ny.startOfDayOffset(noon, 1)), '2026-03-09 00:00');
      expect(
        ny.startOfDayOffset(noon, 1) - ny.startOfDay(noon),
        Duration.millisecondsPerHour * 23,
      );
    });

    test('LocalWallClock round-trips on this machine', () {
      const local = LocalWallClock();
      final t = local.fromWall(2026, 10, 6, 19, 30);
      final w = local.toWall(t);
      expect((w.year, w.month, w.day, w.hour, w.minute), (2026, 10, 6, 19, 30));
      expect(w.weekday, 2); // Tuesday
    });
  });
}
