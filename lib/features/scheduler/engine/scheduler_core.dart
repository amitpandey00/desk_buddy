import 'dart:math';

import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/schedule.dart';
import 'package:desk_buddy/features/scheduler/engine/wall_clock.dart';

// ---------------------------------------------------------------- config

class SchedulerConfig {
  const SchedulerConfig({
    this.snoozeMinutes = 10,
    this.autoMissMinutes = 5,
    this.doNotDisturb = false,
  });

  final int snoozeMinutes;
  final int autoMissMinutes;
  final bool doNotDisturb;
}

/// A wall-time jump bigger than this between ticks means the machine slept.
const sleepGap = Duration(minutes: 2);

// ---------------------------------------------------------------- events

sealed class SchedulerEvent {
  const SchedulerEvent(this.now);

  /// Epoch ms when the event happened.
  final int now;
}

/// Once per second.
final class Tick extends SchedulerEvent {
  const Tick(super.now);
}

/// The full reminder list, whenever it changes (either window).
final class RemindersLoaded extends SchedulerEvent {
  const RemindersLoaded(this.reminders, super.now);
  final List<Reminder> reminders;
}

final class ConfigChanged extends SchedulerEvent {
  const ConfigChanged(this.config, super.now);
  final SchedulerConfig config;
}

/// The user answered the pop-up: [LogAction.done] or [LogAction.snoozed].
final class Respond extends SchedulerEvent {
  const Respond(this.action, super.now, {this.firedAt})
    : assert(action != LogAction.missed, 'missed is decided by the scheduler');
  final LogAction action;

  /// Which pop-up this answers (its `firedAt`). A click on a bubble or
  /// notification that has already been replaced must not answer the new
  /// one, so a mismatch is ignored. Null = whatever is open (tests, tray).
  final int? firedAt;
}

/// "Test" / "Preview": shows a reminder now without logging or rescheduling.
final class TestFire extends SchedulerEvent {
  const TestFire(this.reminderId, super.now);
  final String reminderId;
}

/// Tray: push everything due within [minutes] to [minutes] from now.
final class SnoozeAll extends SchedulerEvent {
  const SnoozeAll(this.minutes, super.now);
  final int minutes;
}

// ---------------------------------------------------------------- effects

sealed class SchedulerEffect {
  const SchedulerEffect();
}

final class ShowAlert extends SchedulerEffect {
  const ShowAlert(this.reminder, {required this.firedAt, required this.test});
  final Reminder reminder;
  final int firedAt;
  final bool test;
}

final class HideAlert extends SchedulerEffect {
  const HideAlert();
}

final class WriteLog extends SchedulerEffect {
  const WriteLog({
    required this.reminderId,
    required this.categoryId,
    required this.at,
    required this.action,
    required this.responseSeconds,
  });

  final String reminderId;
  final String? categoryId;
  final int at;
  final LogAction action;
  final int responseSeconds;
}

/// Write `nextDueAt` (always) and `enabled` (when not null).
final class UpdateSchedule extends SchedulerEffect {
  const UpdateSchedule(this.reminderId, this.nextDueAt, {this.enabled});
  final String reminderId;
  final int? nextDueAt;
  final bool? enabled;
}

// ---------------------------------------------------------------- core

class ActiveAlert {
  const ActiveAlert(this.reminderId, this.firedAt, {required this.test});
  final String reminderId;
  final int firedAt;

  /// Test pop-ups are never logged and never reschedule.
  final bool test;
}

class _Pending {
  const _Pending(
    this.nextDueAt,
    this.baseUpdatedAt, {
    required this.enabled,
  });
  final int? nextDueAt;
  final bool enabled;
  final int baseUpdatedAt;
}

/// The scheduling brain, as a pure state machine: events in, effects out.
/// No timers, no I/O — the service runs the clock and applies effects.
///
/// Rules (spec §5):
/// * one pop-up at a time; the earliest due fires first, the rest queue;
/// * done → next from now (a past one-off disables itself);
///   snoozed → now + snooze; unanswered for autoMiss → missed, next from now;
/// * DND fires nothing (and hides an open pop-up, which stays due);
/// * after sleep, each overdue reminder fires at most once — it only ever
///   has one `nextDueAt`, so there's no backlog to replay — and an interval
///   reminder whose active window has closed is moved to its next window
///   instead of firing.
class SchedulerCore {
  SchedulerCore({required this.wallClock});

  final WallClock wallClock;

  final Map<String, Reminder> _reminders = {};

  /// Schedule writes not yet seen back from the database.
  final Map<String, _Pending> _pending = {};
  SchedulerConfig _config = const SchedulerConfig();
  ActiveAlert? _alert;
  int? _lastTick;
  bool _lastTickWasGap = false;

  ActiveAlert? get alert => _alert;
  SchedulerConfig get config => _config;
  bool get lastTickWasGap => _lastTickWasGap;
  Reminder? reminder(String id) => _reminders[id];

  /// Enabled reminders with a due time, soonest first.
  List<Reminder> upcoming() {
    final list =
        _reminders.values
            .where((r) => r.enabled && r.nextDueAt != null)
            .toList()
          ..sort(_byDue);
    return list;
  }

  static int _byDue(Reminder a, Reminder b) {
    final c = a.nextDueAt!.compareTo(b.nextDueAt!);
    if (c != 0) return c;
    final d = a.createdAt.compareTo(b.createdAt);
    return d != 0 ? d : a.id.compareTo(b.id);
  }

  List<SchedulerEffect> handle(SchedulerEvent e) {
    final out = <SchedulerEffect>[];
    switch (e) {
      case Tick():
        _tick(e.now, out);
      case RemindersLoaded():
        _load(e.reminders, e.now, out);
      case ConfigChanged():
        final wasDnd = _config.doNotDisturb;
        _config = e.config;
        if (!wasDnd && _config.doNotDisturb && _alert != null) {
          _alert = null; // hidden, not logged: it stays due for later
          out.add(const HideAlert());
        }
      case Respond():
        final a = _alert;
        if (a == null) break;
        if (e.firedAt != null && e.firedAt != a.firedAt) break;
        if (a.test) {
          _alert = null;
          out.add(const HideAlert());
        } else {
          _finish(a, e.action, e.now, out);
        }
      case TestFire():
        final r = _reminders[e.reminderId];
        if (r == null) break;
        if (_alert != null) out.add(const HideAlert());
        _alert = ActiveAlert(r.id, e.now, test: true);
        out.add(ShowAlert(r, firedAt: e.now, test: true));
      case SnoozeAll():
        final until = e.now + e.minutes * Duration.millisecondsPerMinute;
        final a = _alert;
        if (a != null) {
          if (a.test) {
            _alert = null;
            out.add(const HideAlert());
          } else {
            _finish(a, LogAction.snoozed, e.now, out, nextOverride: until);
          }
        }
        for (final r in upcoming()) {
          if (r.nextDueAt! < until) _schedule(r, until, out);
        }
    }
    return out;
  }

  void _tick(int now, List<SchedulerEffect> out) {
    final last = _lastTick;
    _lastTickWasGap = last != null && now - last > sleepGap.inMilliseconds;
    _lastTick = now;

    if (_lastTickWasGap) {
      // Woke from sleep: interval reminders that became due while the
      // machine was off and whose active window has since closed move to
      // their next window instead of firing out of hours. Only here — a
      // reminder that waits in the queue, is snoozed past the window end, or
      // is held by DND still fires when its turn comes (spec §5).
      for (final r in upcoming()) {
        if (r.nextDueAt! > now) break;
        if (!mayFireAt(r, now, wallClock)) {
          _schedule(r, fitWindow(r, now, wallClock), out);
        }
      }
    }

    final a = _alert;
    if (a != null) {
      final limit = _config.autoMissMinutes * Duration.millisecondsPerMinute;
      if (_lastTickWasGap && !a.test) {
        // Slept with a pop-up open: it was last seen at the previous tick.
        final seenUntil = min(last!, a.firedAt + limit);
        _finish(
          a,
          LogAction.missed,
          now,
          out,
          seenMs: seenUntil - a.firedAt,
          logAt: seenUntil,
        );
      } else if (now - a.firedAt >= limit || _lastTickWasGap) {
        if (a.test) {
          _alert = null;
          out.add(const HideAlert());
        } else {
          _finish(a, LogAction.missed, now, out, seenMs: limit);
        }
      }
      return;
    }
    if (_config.doNotDisturb) return;

    for (final r in upcoming()) {
      if (r.nextDueAt! > now) break;
      _alert = ActiveAlert(r.id, now, test: false);
      out.add(ShowAlert(r, firedAt: now, test: false));
      return;
    }
  }

  void _finish(
    ActiveAlert a,
    LogAction action,
    int now,
    List<SchedulerEffect> out, {
    int? nextOverride,
    int? seenMs,
    int? logAt,
  }) {
    _alert = null;
    out.add(const HideAlert());
    final r = _reminders[a.reminderId];
    out.add(
      WriteLog(
        reminderId: a.reminderId,
        categoryId: r?.categoryId,
        at: logAt ?? now,
        action: action,
        responseSeconds: ((seenMs ?? now - a.firedAt) / 1000).round(),
      ),
    );
    if (r == null) return;
    final next =
        nextOverride ??
        (action == LogAction.snoozed
            ? now + _config.snoozeMinutes * Duration.millisecondsPerMinute
            : computeNext(r, now, wallClock));
    // A one-off with nothing left to do switches itself off.
    final disable = next == null && r.scheduleType == ScheduleType.once;
    _schedule(r, next, out, enabled: disable ? false : null);
  }

  void _schedule(
    Reminder r,
    int? next,
    List<SchedulerEffect> out, {
    bool? enabled,
  }) {
    final updated = r.copyWith(
      nextDueAt: next,
      enabled: enabled ?? r.enabled,
    );
    _reminders[r.id] = updated;
    _pending[r.id] = _Pending(
      next,
      r.updatedAt,
      enabled: updated.enabled,
    );
    out.add(UpdateSchedule(r.id, next, enabled: enabled));
  }

  void _load(List<Reminder> list, int now, List<SchedulerEffect> out) {
    _reminders.clear();
    final seen = <String>{};
    for (final loaded in list) {
      seen.add(loaded.id);
      var r = loaded;
      final p = _pending[r.id];
      if (p != null) {
        if (r.updatedAt > p.baseUpdatedAt) {
          _pending.remove(r.id); // edited since: the edit wins
        } else if (r.nextDueAt == p.nextDueAt && r.enabled == p.enabled) {
          _pending.remove(r.id); // our write is now visible
        } else {
          // A reload that predates our write: keep what we decided.
          r = r.copyWith(nextDueAt: p.nextDueAt, enabled: p.enabled);
        }
      }
      _reminders[r.id] = r;
    }
    _pending.removeWhere((id, _) => !seen.contains(id));

    // Enabled but unscheduled (seeded, imported, re-enabled elsewhere).
    for (final r in _reminders.values.toList()) {
      if (!r.enabled || r.nextDueAt != null || _pending.containsKey(r.id)) {
        continue;
      }
      final next = computeNext(r, now, wallClock);
      if (next != null) {
        _schedule(r, next, out);
      } else if (r.scheduleType == ScheduleType.once) {
        _schedule(r, null, out, enabled: false);
      }
    }

    final a = _alert;
    final showing = a == null ? null : _reminders[a.reminderId];
    // Deleted, or switched off while showing: just close it. A test pop-up
    // may show a disabled reminder on purpose; it only closes if deleted.
    if (a != null && (showing == null || (!showing.enabled && !a.test))) {
      _alert = null;
      out.add(const HideAlert());
    }
  }
}
