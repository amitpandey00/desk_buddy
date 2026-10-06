import 'dart:math';

import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/wall_clock.dart';

/// Done entries (pop-up or manual) for [reminderId] from local midnight of
/// [now]'s day.
int countToday(
  Iterable<LogEntry> log,
  String reminderId,
  int now,
  WallClock wc,
) {
  final start = wc.startOfDay(now);
  final end = wc.startOfDayOffset(now, 1);
  return log
      .where(
        (l) =>
            l.reminderId == reminderId &&
            l.action == LogAction.done &&
            l.at >= start &&
            l.at < end,
      )
      .length;
}

/// Consecutive days, ending today, on which [r] met its goal. If today
/// isn't met yet, the run is counted from yesterday (so it isn't "lost" in
/// the morning). 0 when the reminder has no goal.
int streak(Iterable<LogEntry> log, Reminder r, int now, WallClock wc) {
  if (r.dailyGoal <= 0) return 0;
  final perDay = <int, int>{};
  for (final l in log) {
    if (l.reminderId == r.id && l.action == LogAction.done) {
      final d = wc.startOfDay(l.at);
      perDay[d] = (perDay[d] ?? 0) + 1;
    }
  }
  var day = wc.startOfDay(now);
  if ((perDay[day] ?? 0) < r.dailyGoal) day = wc.startOfDayOffset(day, -1);
  var n = 0;
  while ((perDay[day] ?? 0) >= r.dailyGoal) {
    n++;
    day = wc.startOfDayOffset(day, -1);
  }
  return n;
}

/// Today's progress across every reminder with a goal: the dashboard ring.
class GoalSummary {
  const GoalSummary(this.have, this.total);

  /// Σ min(count, goal).
  final int have;

  /// Σ goal.
  final int total;

  /// 0–100, rounded; 0 when there are no goals.
  int get percent => total == 0 ? 0 : (have * 100 / total).round();
}

GoalSummary goalSummary(
  Iterable<Reminder> reminders,
  Iterable<LogEntry> log,
  int now,
  WallClock wc,
) {
  var have = 0;
  var total = 0;
  for (final r in reminders.where((r) => r.dailyGoal > 0)) {
    total += r.dailyGoal;
    have += min(countToday(log, r.id, now, wc), r.dailyGoal);
  }
  return GoalSummary(have, total);
}
