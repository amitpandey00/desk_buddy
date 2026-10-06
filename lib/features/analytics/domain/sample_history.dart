import 'dart:math';

import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/schedule.dart';
import 'package:desk_buddy/features/scheduler/engine/wall_clock.dart';

/// Debug-only: plausible history for the last [days] days (not today), so
/// the charts have something to show. Port of the prototype's `seedLog`,
/// derived from each reminder's own schedule — nothing reminder-specific.
/// Every entry is flagged `sample` and can be removed in one go.
List<LogEntry> generateSampleHistory({
  required List<Reminder> reminders,
  required int now,
  required WallClock wallClock,
  required String Function() newId,
  Random? random,
  int days = 6,
}) {
  final rnd = random ?? Random();
  final out = <LogEntry>[];
  for (var d = days; d >= 1; d--) {
    final base = wallClock.startOfDayOffset(now, -d);
    final weekday = wallClock.toWall(base).weekday;
    for (final r in reminders) {
      final minutes = <int>[];
      switch (r.scheduleType) {
        case ScheduleType.interval:
          final a = parseHm(r.activeFrom) ?? 9 * 60;
          final b = parseHm(r.activeTo) ?? 21 * 60;
          final every = max(1, r.everyMinutes);
          for (var m = a + every; m <= b && minutes.length < 16; m += every) {
            minutes.add(m);
          }
        case ScheduleType.daily:
          final t = parseHm(r.timeOfDay);
          if (t != null &&
              (r.daysOfWeek.isEmpty || r.daysOfWeek.contains(weekday))) {
            minutes.add(t);
          }
        case ScheduleType.once:
          break;
      }
      for (final m in minutes) {
        final x = rnd.nextDouble();
        out.add(
          LogEntry(
            id: newId(),
            reminderId: r.id,
            categoryId: r.categoryId,
            at: base + (m + rnd.nextInt(8)) * Duration.millisecondsPerMinute,
            action: x < .7
                ? LogAction.done
                : x < .87
                ? LogAction.snoozed
                : LogAction.missed,
            responseSeconds: 5 + rnd.nextInt(91),
            sample: true,
          ),
        );
      }
    }
  }
  return out;
}
