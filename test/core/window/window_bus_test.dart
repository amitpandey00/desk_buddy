import 'dart:io';

import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/core/db/open_database.dart';
import 'package:desk_buddy/core/window/window_bus.dart';
import 'package:desk_buddy/core/window/window_role.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

class _CountingTransport implements BusTransport {
  _CountingTransport(this.inner);
  final BusTransport inner;
  final sent = <String>[];

  @override
  Future<void> send(String method, Object? arguments) {
    sent.add(method);
    return inner.send(method, arguments);
  }

  @override
  Future<void> listen(Future<Object?> Function(String, Object?) h) =>
      inner.listen(h);

  @override
  Future<void> close() => inner.close();
}

void main() {
  group('WindowRole', () {
    test('main window (empty / junk arguments) is the overlay', () {
      expect(WindowRole.parse(''), WindowRole.overlay);
      expect(WindowRole.parse('{oops'), WindowRole.overlay);
      expect(WindowRole.parse('{"role":"other"}'), WindowRole.overlay);
    });
    test('round-trips the dashboard', () {
      expect(
        WindowRole.parse(WindowRole.dashboard.encode()),
        WindowRole.dashboard,
      );
    });
  });

  group('WindowBus with two connections to one file', () {
    late Directory dir;
    late AppData overlay;
    late AppData dashboard;
    late WindowBus overlayBus;
    late WindowBus dashboardBus;
    late _CountingTransport overlayEnd;
    late _CountingTransport dashboardEnd;
    final tested = <String>[];

    setUp(() async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      dir = Directory.systemTemp.createTempSync('desk_buddy_bus');
      final file = File('${dir.path}${Platform.pathSeparator}db.sqlite');
      overlay = AppData(await openAppDatabase(file: file));
      dashboard = AppData(await openAppDatabase(file: file));
      await overlay.prepare(await realSeed());
      await dashboard.prepare(await realSeed());
      final pair = InMemoryBus();
      overlayEnd = _CountingTransport(pair.a);
      dashboardEnd = _CountingTransport(pair.b);
      tested.clear();
      overlayBus = WindowBus(
        overlay,
        overlayEnd,
        onTestReminder: (id) async => tested.add(id),
      );
      dashboardBus = WindowBus(dashboard, dashboardEnd);
      await overlayBus.start();
      await dashboardBus.start();
    });

    tearDown(() async {
      await overlayBus.dispose();
      await dashboardBus.dispose();
      await overlay.close();
      await dashboard.close();
      dir.deleteSync(recursive: true);
    });

    test('a dashboard edit reaches the overlay’s watch streams', () async {
      // The overlay is listening before the other window writes.
      final renamed = overlay.reminders
          .watchAll()
          .firstWhere((l) => l.first.title == 'Renamed')
          .timeout(const Duration(seconds: 5));
      await pumpEventQueue();
      final first = (await dashboard.reminders.all()).first;
      await dashboard.reminders.save(first.copyWith(title: 'Renamed'));
      expect((await renamed).first.title, 'Renamed');
      expect(dashboardEnd.sent, contains(WindowBus.dataChangedMethod));
    });

    test('overlay settings writes reach the dashboard (tray DND)', () async {
      final dnd = dashboard.settings
          .watch()
          .firstWhere((s) => s.doNotDisturb)
          .timeout(const Duration(seconds: 5));
      await pumpEventQueue();
      await overlay.settings.update((s) => s.copyWith(doNotDisturb: true));
      expect((await dnd).doNotDisturb, isTrue);
    });

    test('without the bus, the other window would not notice', () async {
      // Control: proves the bus is what makes the previous tests pass.
      await dashboardBus.dispose();
      var updated = false;
      final sub = overlay.reminders.watchAll().listen((l) {
        if (l.first.title == 'Silent') updated = true;
      });
      await pumpEventQueue();
      final first = (await dashboard.reminders.all()).first;
      await dashboard.reminders.save(first.copyWith(title: 'Silent'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await sub.cancel();
      expect(updated, isFalse);
    });

    test('refreshing never echoes back', () async {
      await dashboard.settings.update((s) => s.copyWith(userName: 'Sam'));
      await pumpEventQueue();
      expect(dashboardEnd.sent, [WindowBus.dataChangedMethod]);
      expect(overlayEnd.sent, isEmpty);
    });

    test('testReminder reaches the overlay', () async {
      await dashboardBus.testReminder('abc');
      expect(tested, ['abc']);
    });

    test('no peer listening: sends complete quietly', () async {
      await overlayBus.dispose();
      await dashboard.settings.update((s) => s.copyWith(userName: 'X'));
      await dashboardBus.testReminder('nobody');
    });
  });
}
