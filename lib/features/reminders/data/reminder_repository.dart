import 'package:clock/clock.dart';
import 'package:desk_buddy/core/db/app_database.dart';
import 'package:desk_buddy/core/db/data_changes.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class ReminderRepository {
  ReminderRepository(
    this._db,
    this._changes, {
    this._clock = const Clock(),
    String Function()? newId,
  }) : _newId = newId ?? const Uuid().v4;

  final AppDatabase _db;
  final DataChanges _changes;
  final Clock _clock;
  final String Function() _newId;

  String newId() => _newId();

  SimpleSelectStatement<$RemindersTable, ReminderRow> _ordered() =>
      _db.select(_db.reminders)..orderBy([
        (r) => OrderingTerm(expression: r.createdAt),
        (r) => OrderingTerm(expression: r.id),
      ]);

  Stream<List<Reminder>> watchAll() =>
      _ordered().watch().map((rows) => rows.map(_toModel).toList());

  Future<List<Reminder>> all() async =>
      (await _ordered().get()).map(_toModel).toList();

  Future<Reminder?> byId(String id) async {
    final row = await (_db.select(
      _db.reminders,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  // `toCompanion(false)`: an upsert must write nulls too (a data class
  // alone treats null as "leave unchanged" on the update path).
  /// Inserts or replaces [reminder], stamping `updatedAt`. Scheduling
  /// (`nextDueAt`) is the caller's job — the scheduler recomputes it.
  Future<Reminder> save(Reminder reminder) async {
    final saved = reminder.copyWith(updatedAt: _stamp(reminder));
    await _db
        .into(_db.reminders)
        .insertOnConflictUpdate(_toRow(saved).toCompanion(false));
    _changes.notify({DataTopic.reminders});
    return saved;
  }

  Future<void> saveAll(Iterable<Reminder> reminders) async {
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(
        _db.reminders,
        [
          for (final r in reminders)
            _toRow(r.copyWith(updatedAt: _stamp(r))).toCompanion(false),
        ],
      );
    });
    _changes.notify({DataTopic.reminders});
  }

  /// `updatedAt` only ever grows, even if the system clock goes backwards:
  /// the scheduler relies on it to tell a user edit from its own stale
  /// write (D14).
  int _stamp(Reminder r) {
    final now = _clock.now().millisecondsSinceEpoch;
    return now > r.updatedAt ? now : r.updatedAt + 1;
  }

  /// Scheduler write: touches only scheduling columns, so it can't clobber
  /// an edit made in the other window a moment earlier.
  Future<void> setSchedule(String id, {int? nextDueAt, bool? enabled}) async {
    await (_db.update(_db.reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(
        nextDueAt: Value(nextDueAt),
        enabled: enabled == null ? const Value.absent() : Value(enabled),
      ),
    );
    _changes.notify({DataTopic.reminders});
  }

  /// Log rows are kept (they reference the id, not a foreign key).
  Future<void> delete(String id) async {
    await (_db.delete(_db.reminders)..where((r) => r.id.equals(id))).go();
    _changes.notify({DataTopic.reminders});
  }

  static Reminder _toModel(ReminderRow r) => Reminder(
    id: r.id,
    title: r.title,
    categoryId: r.categoryId,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
    emoji: r.emoji,
    messageTemplate: r.messageTemplate,
    scheduleType: r.scheduleType,
    everyMinutes: r.everyMinutes,
    activeFrom: r.activeFrom,
    activeTo: r.activeTo,
    timeOfDay: r.timeOfDay,
    daysOfWeek: r.daysOfWeek,
    date: r.date,
    dailyGoal: r.dailyGoal,
    goalUnit: r.goalUnit,
    propId: r.propId,
    doneLabel: r.doneLabel,
    enabled: r.enabled,
    nextDueAt: r.nextDueAt,
    source: r.source,
  );

  static ReminderRow _toRow(Reminder r) => ReminderRow(
    id: r.id,
    title: r.title,
    emoji: r.emoji,
    messageTemplate: r.messageTemplate,
    categoryId: r.categoryId,
    scheduleType: r.scheduleType,
    everyMinutes: r.everyMinutes,
    activeFrom: r.activeFrom,
    activeTo: r.activeTo,
    timeOfDay: r.timeOfDay,
    daysOfWeek: [...r.daysOfWeek]..sort(),
    date: r.date,
    dailyGoal: r.dailyGoal,
    goalUnit: r.goalUnit,
    propId: r.propId,
    doneLabel: r.doneLabel,
    enabled: r.enabled,
    nextDueAt: r.nextDueAt,
    source: r.source,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  );
}
