import 'dart:io';

import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/core/db/app_database.dart';
import 'package:desk_buddy/core/db/open_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  late Directory dir;
  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    dir = Directory.systemTemp.createTempSync('desk_buddy_db');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  File dbFile() => File('${dir.path}${Platform.pathSeparator}test.sqlite');

  test('file database runs in WAL mode with foreign keys on', () async {
    final db = await openAppDatabase(file: dbFile());
    addTearDown(db.close);
    Future<Object?> pragma(String p) async =>
        (await db.customSelect('PRAGMA $p').getSingle()).data.values.first;
    expect(await pragma('journal_mode'), 'wal');
    expect(await pragma('foreign_keys'), 1);
    expect(await pragma('busy_timeout'), 3000);
  });

  test('two connections (two windows) see each other’s writes', () async {
    final overlay = AppData(await openAppDatabase(file: dbFile()));
    final dashboard = AppData(await openAppDatabase(file: dbFile()));
    addTearDown(() async {
      await overlay.close();
      await dashboard.close();
    });
    await overlay.prepare(await realSeed());
    await dashboard.prepare(await realSeed()); // must not double-seed
    expect(await dashboard.reminders.all(), hasLength(3));

    // Interleaved writes from both sides don't fail with SQLITE_BUSY.
    final cat = (await dashboard.categories.all()).first;
    await Future.wait([
      for (var i = 0; i < 20; i++) ...[
        dashboard.reminders.save(reminder('d$i', cat.id)),
        overlay.settings.saveBuddyPosition(i.toDouble(), 0),
      ],
    ]);
    expect(await overlay.reminders.all(), hasLength(23));
    expect((await dashboard.settings.get()).buddyX, 19);
  });

  group('read-then-write transactions across two connections', () {
    late AppData a;
    late AppData b;
    setUp(() async {
      a = AppData(await openAppDatabase(file: dbFile()));
      b = AppData(await openAppDatabase(file: dbFile()));
      await a.prepare(await realSeed());
    });
    tearDown(() async {
      await a.close();
      await b.close();
    });

    test('a transaction holds the write lock: the other side waits', () async {
      // drift opens transactions with BEGIN IMMEDIATE, so a read-then-write
      // can't lose a race with the other window (no SQLITE_BUSY_SNAPSHOT).
      Future<void>? other;
      await a.db.transaction(() async {
        await a.settings.get();
        other = b.settings.update((s) => s.copyWith(userName: 'B'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await a.db.customStatement(
          "UPDATE settings SET user_name = 'A' WHERE id = 1",
        );
      });
      await other;
      // B waited for A's commit, then applied its change on top.
      expect((await a.settings.get()).userName, 'B');
    });

    test(
      'settings.update and category edits survive concurrent writes',
      () async {
        final cat = (await a.categories.all()).first;
        await Future.wait([
          for (var i = 0; i < 15; i++) ...[
            a.settings.update((s) => s.copyWith(walkSpeed: 20 + i)),
            b.settings.saveBuddyPosition(i.toDouble(), 0),
            b.categories.updateWith(cat.id, (c) => c.copyWith(name: 'N$i')),
          ],
        ]);
        expect((await b.categories.byId(cat.id))!.name, startsWith('N'));
      },
    );
  });

  group('constraints', () {
    late AppData data;
    setUp(() async => data = await memoryData());
    tearDown(() => data.close());

    test('interval must be ≥ 1 minute', () async {
      final c = await data.categories.create();
      await expectLater(
        data.reminders.save(reminder('r', c.id).copyWith(everyMinutes: 0)),
        throwsA(isA<SqliteException>()),
      );
    });

    test('reminders must point at an existing category', () async {
      await expectLater(
        data.reminders.save(reminder('r', 'missing')),
        throwsA(isA<SqliteException>()),
      );
    });

    test('settings and look are single-row tables', () async {
      await expectLater(
        data.db.customStatement(
          'INSERT INTO settings (id, user_name, buddy_size, walk_speed, '
          'walk_enabled, buddy_visible, sound_enabled, snooze_minutes, '
          'auto_miss_minutes, do_not_disturb, theme_mode, launch_at_login) '
          "VALUES (2, 'x', 120, 45, 1, 1, 1, 10, 5, 0, 'system', 0)",
        ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  test('in-memory test databases also enforce foreign keys', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.data.values.first, 1);
  });
}
