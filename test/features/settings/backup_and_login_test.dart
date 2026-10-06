import 'dart:convert';

import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/core/db/data_changes.dart';
import 'package:desk_buddy/core/platform/launch_at_login.dart';
import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/buddy/movement/buddy_pose.dart';
import 'package:desk_buddy/features/buddy/ui/buddy_character.dart';
import 'package:desk_buddy/features/buddy/ui/buddy_view.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/settings/data/backup.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  group('backup', () {
    late AppData source;
    setUp(() async {
      source = await memoryData();
      await source.prepare(await realSeed());
      final r = (await source.reminders.all()).first;
      await source.reminders.save(r.copyWith(nextDueAt: 123));
      await source.log.add(
        LogEntry(id: 'l1', at: 5, action: LogAction.done, reminderId: r.id),
      );
      await source.settings.update(
        (s) => s.copyWith(userName: 'Sam', buddyX: 10, buddyY: 20),
      );
      await source.settings.saveLook(LookPresets.cozy);
    });
    tearDown(() => source.close());

    /// Export → JSON text → parse, as the real files go.
    Future<Backup> roundTrip() async => BackupService.parse(
      jsonDecode(jsonEncode(await BackupService(source).export())),
    );

    test('export → import into another install restores everything', () async {
      final backup = await roundTrip();
      final target = await memoryData();
      addTearDown(target.close);
      // The target already has its own data, which must be replaced.
      await target.prepare(await realSeed());
      await target.categories.create(name: 'Only here');
      await target.log.add(
        const LogEntry(id: 'mine', at: 9, action: LogAction.missed),
      );
      await target.settings.update(
        (s) => s.copyWith(buddyX: 1, buddyY: 2, launchAtLogin: true),
      );
      final topics = <Set<DataTopic>>[];
      target.changes.stream.listen(topics.add);

      await BackupService(target).restore(backup);

      expect(
        (await target.categories.all()).map((c) => c.name),
        (await source.categories.all()).map((c) => c.name),
      );
      final a = await source.reminders.all();
      final b = await target.reminders.all();
      expect(b.map((r) => r.id), a.map((r) => r.id));
      expect(b.map((r) => r.messageTemplate), a.map((r) => r.messageTemplate));
      expect(
        b.every((r) => r.nextDueAt == null),
        isTrue,
        reason: 'the scheduler re-plans from now',
      );
      expect((await target.log.since(0)).single.id, 'l1');
      final s = await target.settings.get();
      expect(s.userName, 'Sam');
      expect((s.buddyX, s.buddyY), (1.0, 2.0), reason: 'position stays local');
      expect(s.launchAtLogin, isTrue, reason: 'login item stays local');
      expect(
        (await target.categories.all()).map((c) => c.name),
        isNot(contains('Only here')),
      );
      expect(await target.settings.getLook(), LookPresets.cozy);
      expect(topics.last, DataTopic.values.toSet());
    });

    test('export leaves screen position out', () async {
      final json = await BackupService(source).export();
      final settings = json['settings']! as Map<String, Object?>;
      expect(settings['buddyX'], isNull);
      expect(json['format'], backupFormat);
      expect(json['version'], backupVersion);
    });

    test('rejects other files, newer versions and damaged data', () {
      Matcher fails(String message) => throwsA(
        isA<BackupException>().having((e) => e.message, 'message', message),
      );
      expect(
        () => BackupService.parse({'hello': 1}),
        fails('That file isn’t a Desk Buddy backup.'),
      );
      expect(
        () => BackupService.parse({'format': backupFormat, 'version': 99}),
        fails('That backup is from a newer version of Desk Buddy.'),
      );
      expect(
        () => BackupService.parse({
          'format': backupFormat,
          'version': 1,
          'categories': <Object>[],
        }),
        fails('That backup has no categories.'),
      );
      expect(
        () => BackupService.parse({
          'format': backupFormat,
          'version': 1,
          'categories': [
            {'id': 'c', 'name': 'A', 'emoji': 'a', 'colorHex': '#000000'},
          ],
          'reminders': [
            {'title': 'no id'},
          ],
        }),
        fails('That backup file is damaged.'),
      );
    });

    test('rejects duplicate ids', () {
      Map<String, Object?> cat(String id) => {
        'id': id,
        'name': 'A',
        'emoji': 'a',
        'colorHex': '#000000',
      };
      expect(
        () => BackupService.parse({
          'format': backupFormat,
          'version': 1,
          'categories': [cat('c'), cat('c')],
        }),
        throwsA(isA<BackupException>()),
      );
    });

    test('repairs what it safely can', () {
      final b = BackupService.parse({
        'format': backupFormat,
        'version': 1,
        'categories': [
          {'id': 'c', 'name': 'A', 'emoji': 'a', 'colorHex': '#000000'},
        ],
        'reminders': [
          {
            'id': 'r',
            'title': 'Orphan',
            'categoryId': 'gone',
            'createdAt': 0,
            'updatedAt': 0,
            'everyMinutes': 0,
            'dailyGoal': -3,
            'nextDueAt': 999,
          },
        ],
        'settings': {'buddySize': 9000},
      });
      final r = b.reminders.single;
      expect(r.categoryId, 'c');
      expect((r.everyMinutes, r.dailyGoal, r.nextDueAt), (1, 0, null));
      expect(b.settings.buddySize, AppSettings.sizeMax);
      expect(b.look, LookPresets.classic);
    });
  });

  group('LaunchAtLoginSync', () {
    late AppData data;
    late FakeLoginItem os;
    setUp(() async {
      data = await memoryData();
      os = FakeLoginItem();
    });
    tearDown(() => data.close());

    test('on start, the OS wins (user turned it off in Windows)', () async {
      await data.settings.update((s) => s.copyWith(launchAtLogin: true));
      os.enabled = false;
      final sync = LaunchAtLoginSync(data.settings, os);
      await sync.start();
      addTearDown(sync.dispose);
      expect((await data.settings.get()).launchAtLogin, isFalse);
      expect(os.calls, isEmpty);
    });

    test('afterwards the setting drives the OS', () async {
      final sync = LaunchAtLoginSync(data.settings, os);
      await sync.start();
      addTearDown(sync.dispose);
      await data.settings.update((s) => s.copyWith(launchAtLogin: true));
      await pumpEventQueue();
      expect(os.enabled, isTrue);
      await data.settings.update((s) => s.copyWith(userName: 'unrelated'));
      await pumpEventQueue();
      expect(os.calls, [true], reason: 'other settings changes are ignored');
    });

    test('if the OS refuses, the setting shows the truth', () async {
      os.refuse = true;
      final sync = LaunchAtLoginSync(data.settings, os);
      await sync.start();
      addTearDown(sync.dispose);
      await data.settings.update((s) => s.copyWith(launchAtLogin: true));
      for (var i = 0; i < 3; i++) {
        await pumpEventQueue();
      }
      expect((await data.settings.get()).launchAtLogin, isFalse);
    });
  });

  testWidgets('without a .riv the buddy is drawn by the painter', (
    tester,
  ) async {
    RiveCharacterFile.reset();
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: BuddyCharacter(
          look: LookPresets.classic,
          state: BuddyState.idle,
          reduceMotion: true,
        ),
      ),
    );
    await tester.runAsync(RiveCharacterFile.load);
    await tester.pump();
    expect(find.byType(BuddyView), findsOneWidget);
  });
}

class FakeLoginItem implements LoginItem {
  bool enabled = false;
  bool refuse = false;
  final calls = <bool>[];

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> setEnabled({required bool enabled}) async {
    calls.add(enabled);
    if (refuse) throw StateError('policy');
    this.enabled = enabled;
  }
}
