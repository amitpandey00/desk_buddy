import 'dart:async';

import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/core/db/data_changes.dart';
import 'package:drift/drift.dart';

/// Carries method calls to the *other* window. Real implementation: a
/// `desktop_multi_window` channel; tests pair two in memory.
abstract interface class BusTransport {
  /// Sends to the peer. Completes quietly if no peer is listening.
  Future<void> send(String method, Object? arguments);

  /// Installs the handler for calls from the peer.
  Future<void> listen(Future<Object?> Function(String, Object?) handler);

  Future<void> close();
}

/// Keeps the two windows in step (spec §3).
///
/// * Every local write (`DataChanges`) goes to the peer as `dataChanged`.
///   The peer marks those tables updated in its own drift connection, so
///   every `.watch()` query there re-runs: providers refresh themselves, and
///   since nothing is written, nothing echoes back.
/// * Commands: `testReminder(id)` (dashboard → overlay). DND, settings and
///   look changes are plain data writes, announced as `dataChanged` with
///   the `settings` / `look` topics (the spec's `setDnd`,
///   `settingsChanged`, `characterChanged`).
class WindowBus {
  WindowBus(this._data, this._transport, {this.onTestReminder});

  static const dataChangedMethod = 'dataChanged';
  static const testReminderMethod = 'testReminder';

  final AppData _data;
  final BusTransport _transport;

  /// Overlay only: show a reminder now (Test / Preview).
  final Future<void> Function(String reminderId)? onTestReminder;

  StreamSubscription<Set<DataTopic>>? _sub;

  Future<void> start() async {
    await _transport.listen(_handle);
    _sub = _data.changes.stream.listen(
      (topics) => unawaited(
        _transport.send(dataChangedMethod, [for (final t in topics) t.name]),
      ),
    );
  }

  /// Asks the overlay to pop [reminderId] up now.
  Future<void> testReminder(String reminderId) =>
      _transport.send(testReminderMethod, reminderId);

  Future<Object?> _handle(String method, Object? args) async {
    switch (method) {
      case dataChangedMethod:
        final names = (args! as List<Object?>).cast<String>();
        refreshLocal({
          for (final n in names) ...DataTopic.values.where((t) => t.name == n),
        });
      case testReminderMethod:
        await onTestReminder?.call(args! as String);
    }
    return null;
  }

  /// Re-runs this window's queries over the given tables.
  void refreshLocal(Set<DataTopic> topics) {
    final db = _data.db;
    final tables = <TableInfo<Table, Object?>>{
      for (final t in topics)
        ...switch (t) {
          DataTopic.categories => [db.categories],
          // A category delete also moves reminders, and both screens show
          // category names next to reminders.
          DataTopic.reminders => [db.reminders],
          DataTopic.log => [db.logEntries],
          DataTopic.settings => [db.settingsTable],
          DataTopic.look => [db.buddyLooks],
        },
    };
    if (tables.isNotEmpty) db.markTablesUpdated(tables);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _transport.close();
  }
}

/// Two transports wired to each other (tests).
class InMemoryBus {
  InMemoryBus() {
    a = _End(this);
    b = _End(this);
  }

  late final BusTransport a;
  late final BusTransport b;
}

class _End implements BusTransport {
  _End(this._bus);
  final InMemoryBus _bus;
  Future<Object?> Function(String, Object?)? _handler;

  _End get _peer => identical(this, _bus.a) ? _bus.b as _End : _bus.a as _End;

  @override
  Future<void> send(String method, Object? arguments) async {
    await _peer._handler?.call(method, arguments);
  }

  @override
  Future<void> listen(
    Future<Object?> Function(String, Object?) handler,
  ) async => _handler = handler;

  @override
  Future<void> close() async => _handler = null;
}
