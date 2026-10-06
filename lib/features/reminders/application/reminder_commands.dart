import 'package:clock/clock.dart';
import 'package:desk_buddy/features/reminders/data/log_repository.dart';
import 'package:desk_buddy/features/reminders/data/reminder_repository.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/schedule.dart';
import 'package:desk_buddy/features/scheduler/engine/wall_clock.dart';
import 'package:desk_buddy/shared/strings.dart';

/// Why a reminder can't be saved (the editor shows [message]).
enum ReminderProblem {
  titleMissing(Strings.problemTitleMissing),
  dateMissing(Strings.problemDateMissing),
  intervalTooShort(Strings.problemIntervalTooShort),
  timePassed(Strings.problemTimePassed);

  const ReminderProblem(this.message);
  final String message;
}

/// Every user-initiated change to reminders goes through here, so
/// `nextDueAt` is always recomputed from *now* when the schedule could have
/// changed (spec §5: enabling and editing recompute).
class ReminderCommands {
  ReminderCommands(
    this._reminders,
    this._log, {
    this._clock = const Clock(),
    this._wallClock = const LocalWallClock(),
  });

  final ReminderRepository _reminders;
  final LogRepository _log;
  final Clock _clock;
  final WallClock _wallClock;

  int get _now => _clock.now().millisecondsSinceEpoch;

  /// The first problem with [r], or null if it can be saved.
  ReminderProblem? validate(Reminder r) {
    if (r.title.trim().isEmpty) return ReminderProblem.titleMissing;
    if (r.scheduleType == ScheduleType.interval && r.everyMinutes < 1) {
      return ReminderProblem.intervalTooShort;
    }
    if (r.scheduleType == ScheduleType.once) {
      if (parseDate(r.date) == null) return ReminderProblem.dateMissing;
      // A one-off that already fired is switched off and may still be
      // renamed or kept; only an enabled one must lie in the future.
      if (r.enabled && computeNext(r, _now, _wallClock) == null) {
        return ReminderProblem.timePassed;
      }
    }
    return null;
  }

  /// Validates, schedules from now (if enabled), and saves. Throws
  /// [ArgumentError] for an invalid reminder — callers validate first.
  Future<Reminder> save(Reminder r) {
    final problem = validate(r);
    if (problem != null) throw ArgumentError(problem.message);
    final cleaned = r.copyWith(
      title: r.title.trim(),
      everyMinutes: r.everyMinutes < 1 ? 1 : r.everyMinutes,
      dailyGoal: r.dailyGoal < 0 ? 0 : r.dailyGoal,
      goalUnit: r.goalUnit.trim(),
    );
    return _reminders.save(
      cleaned.copyWith(
        nextDueAt: cleaned.enabled
            ? computeNext(cleaned, _now, _wallClock)
            : null,
      ),
    );
  }

  /// A brand-new reminder's id and timestamps.
  Reminder blank({required String categoryId}) => Reminder(
    id: _reminders.newId(),
    title: '',
    categoryId: categoryId,
    createdAt: _now,
    updatedAt: _now,
    messageTemplate: Strings.newReminderMessage,
  );

  Future<void> setEnabled(String id, {required bool enabled}) async {
    final r = await _reminders.byId(id);
    if (r == null) return;
    // A one-off whose time has passed can't be switched back on.
    if (enabled &&
        r.scheduleType == ScheduleType.once &&
        computeNext(r, _now, _wallClock) == null) {
      return;
    }
    // A full save (not setSchedule) so updatedAt moves and this user edit
    // wins over any pending scheduler write in the overlay.
    await _reminders.save(
      r.copyWith(
        enabled: enabled,
        nextDueAt: enabled ? computeNext(r, _now, _wallClock) : null,
      ),
    );
  }

  Future<void> delete(String id) => _reminders.delete(id);

  /// The dashboard's "+1": a done entry that isn't a pop-up response.
  Future<void> logManual(Reminder r) => _log.add(
    LogEntry(
      id: _log.newId(),
      reminderId: r.id,
      categoryId: r.categoryId,
      at: _now,
      action: LogAction.done,
      manual: true,
    ),
  );
}
