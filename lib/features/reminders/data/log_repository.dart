import 'package:desk_buddy/core/db/app_database.dart';
import 'package:desk_buddy/core/db/data_changes.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// How long history is kept.
const logRetentionDays = 90;

class LogRepository {
  LogRepository(this._db, this._changes, {String Function()? newId})
    : _newId = newId ?? const Uuid().v4;

  final AppDatabase _db;
  final DataChanges _changes;
  final String Function() _newId;

  String newId() => _newId();

  SimpleSelectStatement<$LogEntriesTable, LogEntryRow> _since(
    int fromMs, {
    String? reminderId,
  }) => _db.select(_db.logEntries)
    ..where(
      (l) =>
          l.at.isBiggerOrEqualValue(fromMs) &
          (reminderId == null
              ? const Constant(true)
              : l.reminderId.equals(reminderId)),
    )
    ..orderBy([(l) => OrderingTerm(expression: l.at)]);

  /// Entries at or after [fromMs], oldest first.
  Stream<List<LogEntry>> watchSince(int fromMs) =>
      _since(fromMs).watch().map((rows) => rows.map(_toModel).toList());

  Future<List<LogEntry>> since(int fromMs, {String? reminderId}) async =>
      (await _since(
        fromMs,
        reminderId: reminderId,
      ).get()).map(_toModel).toList();

  Future<void> add(LogEntry entry) async {
    await _db.into(_db.logEntries).insert(_toRow(entry));
    _changes.notify({DataTopic.log});
  }

  Future<void> addAll(Iterable<LogEntry> entries) async {
    await _db.batch(
      (b) => b.insertAll(_db.logEntries, entries.map(_toRow).toList()),
    );
    _changes.notify({DataTopic.log});
  }

  /// Deletes entries older than [cutoffMs]; returns how many.
  Future<int> pruneBefore(int cutoffMs) async {
    final n = await (_db.delete(
      _db.logEntries,
    )..where((l) => l.at.isSmallerThanValue(cutoffMs))).go();
    if (n > 0) _changes.notify({DataTopic.log});
    return n;
  }

  Stream<bool> watchHasSamples() =>
      (_db.selectOnly(_db.logEntries)
            ..addColumns([_db.logEntries.id])
            ..where(_db.logEntries.sample.equals(true))
            ..limit(1))
          .watch()
          .map((rows) => rows.isNotEmpty);

  Future<int> deleteSamples() async {
    final n = await (_db.delete(
      _db.logEntries,
    )..where((l) => l.sample.equals(true))).go();
    if (n > 0) _changes.notify({DataTopic.log});
    return n;
  }

  static LogEntry _toModel(LogEntryRow r) => LogEntry(
    id: r.id,
    at: r.at,
    action: r.action,
    reminderId: r.reminderId,
    categoryId: r.categoryId,
    responseSeconds: r.responseSeconds,
    manual: r.manual,
    sample: r.sample,
  );

  static LogEntryRow _toRow(LogEntry e) => LogEntryRow(
    id: e.id,
    reminderId: e.reminderId,
    categoryId: e.categoryId,
    at: e.at,
    action: e.action,
    responseSeconds: e.responseSeconds,
    manual: e.manual,
    sample: e.sample,
  );
}
