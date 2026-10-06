import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/goals.dart';
import 'package:desk_buddy/shared/template/fill_template.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/tz_wall_clock.dart';

void main() {
  group('fillTemplate', () {
    const ctx = TemplateContext(
      name: 'Sam',
      title: 'Read',
      count: 3,
      goal: 10,
      unit: 'pages',
      category: 'Personal',
    );

    test('fills every token', () {
      expect(
        fillTemplate('{name}: {title} {count}/{goal} {unit} ({category})', ctx),
        'Sam: Read 3/10 pages (Personal)',
      );
    });

    test('unknown tokens and stray braces stay as written', () {
      expect(fillTemplate('Hi {nmae} {} {', ctx), 'Hi {nmae} {} {');
    });

    test('no goal renders {goal} as empty', () {
      const noGoal = TemplateContext(
        name: 'Sam',
        title: 't',
        count: 0,
        goal: 0,
        unit: '',
        category: 'c',
      );
      expect(fillTemplate('[{goal}]', noGoal), '[]');
    });

    test('repeated tokens and no tokens', () {
      expect(fillTemplate('{name} {name}', ctx), 'Sam Sam');
      expect(fillTemplate('plain', ctx), 'plain');
    });
  });

  group('goals', () {
    final ny = TzWallClock('America/New_York');
    var n = 0;
    LogEntry log(
      int at, {
      String rid = 'r',
      LogAction action = LogAction.done,
      bool manual = false,
    }) => LogEntry(
      id: '${n++}',
      at: at,
      action: action,
      reminderId: rid,
      manual: manual,
    );
    Reminder goal(int g) => Reminder(
      id: 'r',
      title: 'r',
      categoryId: 'c',
      createdAt: 0,
      updatedAt: 0,
      dailyGoal: g,
    );

    test('countToday: done only, manual included, this reminder, today', () {
      final now = ny.at(2026, 10, 6, 15);
      final entries = [
        log(ny.at(2026, 10, 6)), // midnight counts
        log(ny.at(2026, 10, 6, 9), manual: true),
        log(ny.at(2026, 10, 6, 10), action: LogAction.snoozed),
        log(ny.at(2026, 10, 6, 11), action: LogAction.missed),
        log(ny.at(2026, 10, 6, 12), rid: 'other'),
        log(ny.at(2026, 10, 5, 23, 59)), // yesterday
      ];
      expect(countToday(entries, 'r', now, ny), 2);
    });

    test('streak counts back from today when today is met', () {
      final entries = [
        for (final d in [3, 4, 5, 6]) ...[
          log(ny.at(2026, 10, d, 9)),
          log(ny.at(2026, 10, d, 10)),
        ],
      ];
      expect(streak(entries, goal(2), ny.at(2026, 10, 6, 20), ny), 4);
    });

    test('streak starts from yesterday while today is unmet', () {
      final entries = [
        for (final d in [4, 5]) ...[
          log(ny.at(2026, 10, d, 9)),
          log(ny.at(2026, 10, d, 10)),
        ],
        log(ny.at(2026, 10, 6, 9)), // 1 of 2 so far today
      ];
      expect(streak(entries, goal(2), ny.at(2026, 10, 6, 11), ny), 2);
    });

    test('a missed day breaks the streak', () {
      final entries = [
        log(ny.at(2026, 10, 3, 9)),
        log(ny.at(2026, 10, 5, 9)),
        log(ny.at(2026, 10, 6, 9)),
      ];
      expect(streak(entries, goal(1), ny.at(2026, 10, 6, 12), ny), 2);
    });

    test('streak survives a DST day (23-hour day)', () {
      final entries = [
        for (final d in [7, 8, 9]) log(ny.at(2026, 3, d, 23, 30)),
      ];
      expect(streak(entries, goal(1), ny.at(2026, 3, 9, 23, 45), ny), 3);
    });

    test('no goal → no streak', () {
      expect(
        streak([log(ny.at(2026, 10, 6))], goal(0), ny.at(2026, 10, 6), ny),
        0,
      );
    });

    test('ring: Σ min(count, goal) / Σ goal over goal reminders only', () {
      final now = ny.at(2026, 10, 6, 15);
      final a = goal(8);
      final b = goal(2).copyWith(id: 'b');
      final none = goal(0).copyWith(id: 'none');
      final entries = [
        for (var i = 0; i < 4; i++) log(ny.at(2026, 10, 6, 9)),
        for (var i = 0; i < 5; i++) log(ny.at(2026, 10, 6, 9), rid: 'b'),
        log(ny.at(2026, 10, 6, 9), rid: 'none'),
      ];
      final s = goalSummary([a, b, none], entries, now, ny);
      expect((s.have, s.total, s.percent), (6, 10, 60));
      expect(goalSummary([none], entries, now, ny).percent, 0);
    });
  });
}
