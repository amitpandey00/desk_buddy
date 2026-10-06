import 'package:desk_buddy/features/categories/domain/category.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/wall_clock.dart';

/// One row of the "By reminder" table.
class ReminderStats {
  const ReminderStats(this.reminder, this.done, this.snoozed, this.missed);

  final Reminder reminder;
  final int done;
  final int snoozed;
  final int missed;

  /// Done ÷ pop-up responses, or null when it never popped up.
  int? get completionPercent {
    final n = done + snoozed + missed;
    return n == 0 ? null : (done * 100 / n).round();
  }
}

/// The last 7 days (today included), as the Analytics screen shows them.
/// All counts come from data; nothing knows about particular reminders.
class WeekAnalytics {
  WeekAnalytics._({
    required this.dayStarts,
    required this.completedPerDay,
    required this.done,
    required this.snoozed,
    required this.missed,
    required this.completionPercent,
    required this.averageResponseSeconds,
    required this.completedByHour,
    required this.perReminder,
    required this.isEmpty,
  });

  /// Computes the week ending on [now]'s day.
  factory WeekAnalytics.compute({
    required List<Reminder> reminders,
    required List<Category> categories,
    required List<LogEntry> log,
    required int now,
    required WallClock wallClock,
  }) {
    final wc = wallClock;
    final days = [for (var i = -6; i <= 0; i++) wc.startOfDayOffset(now, i)];
    final end = wc.startOfDayOffset(now, 1);
    final week = log.where((l) => l.at >= days.first && l.at < end).toList();
    final known = {for (final c in categories) c.id};

    int dayIndex(int at) {
      for (var i = days.length - 1; i >= 0; i--) {
        if (at >= days[i]) return i;
      }
      return 0;
    }

    final perDay = List.generate(7, (_) => <String?, int>{});
    final byHour = List.filled(24, 0);
    var done = 0;
    var snoozed = 0;
    var missed = 0;
    var popupResponses = 0;
    var popupDone = 0;
    var responseTotal = 0;
    var responseCount = 0;

    for (final l in week) {
      switch (l.action) {
        case LogAction.done:
          done++;
          final cat = known.contains(l.categoryId) ? l.categoryId : null;
          final day = perDay[dayIndex(l.at)];
          day[cat] = (day[cat] ?? 0) + 1;
          byHour[wc.toWall(l.at).hour]++;
        case LogAction.snoozed:
          snoozed++;
        case LogAction.missed:
          missed++;
      }
      if (!l.manual) {
        popupResponses++;
        if (l.action == LogAction.done) {
          popupDone++;
          if (l.responseSeconds > 0) {
            responseTotal += l.responseSeconds;
            responseCount++;
          }
        }
      }
    }

    final rows = [
      for (final r in reminders)
        () {
          final mine = week.where((l) => l.reminderId == r.id && !l.manual);
          int count(LogAction a) => mine.where((l) => l.action == a).length;
          return ReminderStats(
            r,
            count(LogAction.done),
            count(LogAction.snoozed),
            count(LogAction.missed),
          );
        }(),
    ];

    return WeekAnalytics._(
      dayStarts: days,
      completedPerDay: perDay,
      done: done,
      snoozed: snoozed,
      missed: missed,
      completionPercent: popupResponses == 0
          ? 0
          : (popupDone * 100 / popupResponses).round(),
      averageResponseSeconds: responseCount == 0
          ? 0
          : (responseTotal / responseCount).round(),
      completedByHour: byHour,
      perReminder: rows,
      isEmpty: week.isEmpty,
    );
  }

  /// Local midnight of each of the 7 days, oldest first.
  final List<int> dayStarts;

  /// Per day: category id → completed count. `null` = a category that no
  /// longer exists (shown as "Other").
  final List<Map<String?, int>> completedPerDay;

  /// All done entries, manual +1s included.
  final int done;
  final int snoozed;
  final int missed;

  /// Of pop-up responses (manual entries excluded), the % that were done.
  final int completionPercent;

  /// Mean response time of pop-ups answered with done.
  final int averageResponseSeconds;

  /// Completions by hour of day (24 values).
  final List<int> completedByHour;
  final List<ReminderStats> perReminder;
  final bool isEmpty;

  /// Category keys with at least one completion this week (legend).
  Set<String?> get usedCategoryKeys => {
    for (final d in completedPerDay)
      for (final e in d.entries)
        if (e.value > 0) e.key,
  };

  int get maxCompletedInADay => completedPerDay.fold(
    0,
    (m, d) => d.values.fold(0, (a, b) => a + b) > m
        ? d.values.fold(0, (a, b) => a + b)
        : m,
  );
}

/// Completions of [reminder] on each of [dayStarts] (manual included).
List<int> goalSeries(
  Reminder reminder,
  List<LogEntry> log,
  List<int> dayStarts,
  WallClock wc,
) => [
  for (final start in dayStarts)
    () {
      final end = wc.startOfDayOffset(start, 1);
      return log
          .where(
            (l) =>
                l.reminderId == reminder.id &&
                l.action == LogAction.done &&
                l.at >= start &&
                l.at < end,
          )
          .length;
    }(),
];
