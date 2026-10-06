import 'dart:math';

import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/wall_clock.dart';

/// `HH:mm` → minutes after midnight; null if absent or malformed.
int? parseHm(String? hm) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(hm?.trim() ?? '');
  if (m == null) return null;
  final h = int.parse(m.group(1)!);
  final min = int.parse(m.group(2)!);
  return h < 24 && min < 60 ? h * 60 + min : null;
}

/// `yyyy-MM-dd` → (y, m, d); null if malformed.
(int, int, int)? parseDate(String? date) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(date?.trim() ?? '');
  if (m == null) return null;
  return (
    int.parse(m.group(1)!),
    int.parse(m.group(2)!),
    int.parse(m.group(3)!),
  );
}

/// How far ahead a daily reminder looks for an allowed weekday.
const dailySearchDays = 8;

/// When [r] should next fire after [fromMs], or null if never.
///
/// * interval — `from + everyMinutes` (elapsed time), then fitted into the
///   active window (see [fitWindow]).
/// * daily — the first `timeOfDay` strictly after `from` on an allowed
///   weekday (any weekday if `daysOfWeek` is empty), looking up to 8 days.
/// * once — `date + timeOfDay` if still in the future.
///
/// Everything is local wall-clock time: a 07:00 reminder stays at 07:00
/// across DST changes.
int? computeNext(Reminder r, int fromMs, WallClock wc) {
  switch (r.scheduleType) {
    case ScheduleType.interval:
      final every = max(1, r.everyMinutes);
      return fitWindow(r, fromMs + every * Duration.millisecondsPerMinute, wc);
    case ScheduleType.daily:
      final mins = parseHm(r.timeOfDay);
      if (mins == null) return null;
      final f = wc.toWall(fromMs);
      for (var i = 0; i < dailySearchDays; i++) {
        final t = wc.fromWall(
          f.year,
          f.month,
          f.day + i,
          mins ~/ 60,
          mins % 60,
        );
        if (t <= fromMs) continue;
        if (r.daysOfWeek.isEmpty ||
            r.daysOfWeek.contains(wc.toWall(t).weekday)) {
          return t;
        }
      }
      return null;
    case ScheduleType.once:
      final d = parseDate(r.date);
      final mins = parseHm(r.timeOfDay);
      if (d == null || mins == null) return null;
      final t = wc.fromWall(d.$1, d.$2, d.$3, mins ~/ 60, mins % 60);
      return t > fromMs ? t : null;
  }
}

/// Moves [t] into the reminder's active window if it falls outside it.
///
/// No window (either end missing) → unchanged. A normal window (08:00–22:00)
/// is inclusive at both ends; before it → that day's start, after it → the
/// next day's start. An overnight window (22:00–02:00) covers both sides of
/// midnight; in the daytime gap → that evening's start.
int fitWindow(Reminder r, int t, WallClock wc) {
  final a = parseHm(r.activeFrom);
  final b = parseHm(r.activeTo);
  if (a == null || b == null) return t;
  final w = wc.toWall(t);
  final m = w.minuteOfDay;
  if (insideWindow(m, a, b)) return t;
  final dayOffset = (a <= b && m > b) ? 1 : 0;
  return wc.fromWall(w.year, w.month, w.day + dayOffset, a ~/ 60, a % 60);
}

/// Whether minute-of-day [m] is inside the window [a]..[b] (both inclusive,
/// [a] > [b] meaning it wraps past midnight).
bool insideWindow(int m, int a, int b) =>
    a <= b ? (m >= a && m <= b) : (m >= a || m <= b);

/// Whether [r] may fire at [t] — false only for an interval reminder whose
/// active window doesn't include [t] (e.g. it became due while the computer
/// was asleep and the window has since closed).
bool mayFireAt(Reminder r, int t, WallClock wc) {
  if (r.scheduleType != ScheduleType.interval) return true;
  final a = parseHm(r.activeFrom);
  final b = parseHm(r.activeTo);
  if (a == null || b == null) return true;
  return insideWindow(wc.toWall(t).minuteOfDay, a, b);
}
