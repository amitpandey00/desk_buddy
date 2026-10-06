import 'dart:async';
import 'dart:developer' as developer;

import 'package:clock/clock.dart';
import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/features/categories/domain/category.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/application/alert_view.dart';
import 'package:desk_buddy/features/scheduler/engine/goals.dart';
import 'package:desk_buddy/features/scheduler/engine/scheduler_core.dart';
import 'package:desk_buddy/features/scheduler/engine/wall_clock.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:desk_buddy/shared/template/fill_template.dart';

/// Runs the [SchedulerCore] in the overlay window: ticks it every second,
/// feeds it data changes, and carries out its effects — database writes,
/// the bubble, the chime and the notification fallback.
///
/// Only the overlay runs one; it's the single writer of `nextDueAt` via
/// `setSchedule` (user edits go through `ReminderCommands`, which bump
/// `updatedAt` so they win over a pending scheduler write).
class SchedulerService {
  SchedulerService(
    this._data, {
    this._clock = const Clock(),
    WallClock wallClock = const LocalWallClock(),
    this._chime = silentChime,
    this._notifier = const NoAlertNotifier(),
    this._tickEvery = const Duration(seconds: 1),
    void Function(Object error, StackTrace stack)? onError,
  }) : _onError = onError ?? _logError,
       _wallClock = wallClock,
       _core = SchedulerCore(wallClock: wallClock);

  final AppData _data;
  final Clock _clock;
  final WallClock _wallClock;
  final PlayChime _chime;
  final AlertNotifier _notifier;
  final Duration _tickEvery;
  final SchedulerCore _core;
  final void Function(Object, StackTrace) _onError;
  bool _disposed = false;

  static void _logError(Object error, StackTrace stack) =>
      developer.log('effect failed', error: error, stackTrace: stack);

  final _alerts = StreamController<AlertView?>.broadcast();
  final _subs = <StreamSubscription<Object?>>[];
  Timer? _timer;
  Future<void> _effects = Future.value();
  AppSettings _settings = const AppSettings();
  Map<String, Category> _categories = const {};
  AlertView? _current;

  /// The pop-up to show (null = none). Emits on every change.
  Stream<AlertView?> get alerts => _alerts.stream;
  AlertView? get current => _current;

  /// Enabled reminders with a due time, soonest first (for the peek).
  List<Reminder> upcoming() => _core.upcoming();

  int get _now => _clock.now().millisecondsSinceEpoch;

  /// Loads state, starts listening, and (unless [autoTick] is false, for
  /// tests) ticks every second.
  Future<void> start({bool autoTick = true}) async {
    _settings = await _data.settings.get();
    _categories = {for (final c in await _data.categories.all()) c.id: c};
    if (_disposed) return;
    await _dispatch(ConfigChanged(_config(_settings), _now));
    await _dispatch(RemindersLoaded(await _data.reminders.all(), _now));
    if (_disposed) return;

    _subs
      ..add(
        _data.reminders.watchAll().listen(
          (list) => _dispatch(RemindersLoaded(list, _now)),
        ),
      )
      ..add(
        _data.settings.watch().listen((s) {
          _settings = s;
          unawaited(_dispatch(ConfigChanged(_config(s), _now)));
        }),
      )
      ..add(
        _data.categories.watchAll().listen(
          (list) => _categories = {for (final c in list) c.id: c},
        ),
      );
    if (autoTick) _timer = Timer.periodic(_tickEvery, (_) => tick());
  }

  static SchedulerConfig _config(AppSettings s) => SchedulerConfig(
    snoozeMinutes: s.snoozeMinutes,
    autoMissMinutes: s.autoMissMinutes,
    doNotDisturb: s.doNotDisturb,
  );

  /// One scheduler step at the current time (the timer calls this).
  Future<void> tick() => _dispatch(Tick(_now));

  /// The user answered the pop-up that fired at [firedAt] (ignored if a
  /// newer one has replaced it in the meantime).
  Future<void> respond(LogAction action, {int? firedAt}) =>
      _dispatch(Respond(action, _now, firedAt: firedAt));

  /// "Test" / "Preview next reminder".
  Future<void> testFire(String reminderId) =>
      _dispatch(TestFire(reminderId, _now));

  /// Tray: "Snooze all for 30 min".
  Future<void> snoozeAll(int minutes) => _dispatch(SnoozeAll(minutes, _now));

  /// Decides synchronously (so state is always current), then applies the
  /// effects strictly in order, after any earlier ones.
  Future<void> _dispatch(SchedulerEvent e) {
    if (_disposed) return _effects;
    final fx = _core.handle(e);
    if (fx.isEmpty) return _effects;
    return _effects = _effects.then((_) => _apply(fx));
  }

  /// Each effect is isolated: one failing (a busy database, a notification
  /// the OS refuses) is reported and the rest — and every later batch —
  /// still run. Otherwise one error would stop the scheduler for good.
  Future<void> _apply(List<SchedulerEffect> effects) async {
    for (final f in effects) {
      try {
        await _applyOne(f);
      } on Object catch (e, st) {
        _onError(e, st);
      }
    }
  }

  Future<void> _applyOne(SchedulerEffect f) async {
    // After dispose only the bookkeeping writes still run (no UI).
    if (_disposed && f is! WriteLog && f is! UpdateSchedule) return;
    switch (f) {
      case WriteLog():
        await _data.log.add(
          LogEntry(
            id: _data.log.newId(),
            reminderId: f.reminderId,
            categoryId: f.categoryId,
            at: f.at,
            action: f.action,
            responseSeconds: f.responseSeconds,
          ),
        );
      case UpdateSchedule():
        await _data.reminders.setSchedule(
          f.reminderId,
          nextDueAt: f.nextDueAt,
          enabled: f.enabled,
        );
      case ShowAlert():
        await _show(await _view(f));
      case HideAlert():
        _publish(null);
        await _notifier.dismiss();
    }
  }

  Future<void> _show(AlertView view) async {
    _publish(view);
    if (_settings.soundEnabled) unawaited(_chime());
    if (!_settings.buddyVisible) {
      await _notifier.show(
        view,
        onDone: () => respond(LogAction.done, firedAt: view.firedAt),
        onSnooze: () => respond(LogAction.snoozed, firedAt: view.firedAt),
      );
    }
  }

  void _publish(AlertView? view) {
    _current = view;
    if (!_alerts.isClosed) _alerts.add(view);
  }

  Future<AlertView> _view(ShowAlert f) async {
    final r = f.reminder;
    final todays = await _data.log.since(
      _wallClock.startOfDay(f.firedAt),
      reminderId: r.id,
    );
    final count = countToday(todays, r.id, f.firedAt, _wallClock);
    final template = r.messageTemplate.trim().isEmpty
        ? r.title
        : r.messageTemplate;
    return AlertView(
      reminder: r,
      message: fillTemplate(
        template,
        TemplateContext(
          name: _settings.userName,
          title: r.title,
          count: count,
          goal: r.dailyGoal,
          unit: r.goalUnit,
          category: _categories[r.categoryId]?.name ?? '',
        ),
      ).trim(),
      progress: r.dailyGoal > 0
          ? Strings.goalProgress(count, r.dailyGoal, r.goalUnit)
          : null,
      doneLabel: r.doneLabel.trim().isEmpty
          ? Strings.defaultDoneLabel
          : r.doneLabel,
      snoozeLabel: Strings.remindLater(_settings.snoozeMinutes),
      firedAt: f.firedAt,
      test: f.test,
    );
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    for (final s in _subs) {
      await s.cancel();
    }
    // Pending log / schedule writes still land; then nothing more runs.
    await _effects;
    try {
      await _notifier.dismiss();
    } on Object catch (e, st) {
      _onError(e, st);
    }
    await _alerts.close();
  }
}
