import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/core/db/data_changes.dart';
import 'package:desk_buddy/features/buddy/data/buddy_position_store.dart';
import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  late AppData data;
  setUp(() async => data = await memoryData());
  tearDown(() => data.close());

  test('fresh database has the spec defaults', () async {
    final s = await data.settings.get();
    expect(s, const AppSettings());
    expect(s.userName, 'there');
    expect((s.buddySize, s.walkSpeed), (120, 45));
    expect((s.snoozeMinutes, s.autoMissMinutes), (10, 5));
    expect(s.themeMode, ThemePreference.system);
    expect(await data.settings.getLook(), LookPresets.classic);
  });

  test('ensureRows never overwrites existing values', () async {
    await data.settings.save(const AppSettings(userName: 'Sam'));
    await data.settings.ensureRows();
    expect((await data.settings.get()).userName, 'Sam');
  });

  test('save normalizes out-of-range values', () async {
    final s = await data.settings.save(
      const AppSettings(
        userName: '  ',
        buddySize: 999,
        walkSpeed: 1,
        snoozeMinutes: 12,
        autoMissMinutes: 100,
      ),
    );
    expect(s.userName, 'there');
    expect((s.buddySize, s.walkSpeed), (220, 10));
    expect(s.snoozeMinutes, 10);
    expect(s.autoMissMinutes, 15);
    expect(await data.settings.get(), s);
  });

  test('update is read-modify-write and announces settings', () async {
    final topics = <Set<DataTopic>>[];
    data.changes.stream.listen(topics.add);
    await data.settings.update((s) => s.copyWith(doNotDisturb: true));
    expect((await data.settings.get()).doNotDisturb, isTrue);
    expect(topics, [
      {DataTopic.settings},
    ]);
  });

  test('saving null clears the position (regression)', () async {
    await data.settings.save(const AppSettings(buddyX: 1, buddyY: 2));
    await data.settings.update((s) => s.copyWith(buddyX: null, buddyY: null));
    final s = await data.settings.get();
    expect((s.buddyX, s.buddyY), (null, null));
  });

  test('look round-trips and announces look', () async {
    final topics = <Set<DataTopic>>[];
    data.changes.stream.listen(topics.add);
    await data.settings.saveLook(LookPresets.cozy);
    expect(await data.settings.getLook(), LookPresets.cozy);
    expect(topics, [
      {DataTopic.look},
    ]);
  });

  group('SettingsBuddyPositionStore', () {
    test('null until saved, then round-trips', () async {
      final store = SettingsBuddyPositionStore(data.settings);
      expect(await store.load(), isNull);
      await store.save(const BuddyPosition(-1720, 980.5));
      expect(await store.load(), const BuddyPosition(-1720, 980.5));
    });

    test('saving position never clobbers other settings', () async {
      final store = SettingsBuddyPositionStore(data.settings);
      // Another window changes a setting after this one last read them.
      await data.settings.update((s) => s.copyWith(snoozeMinutes: 30));
      await store.save(const BuddyPosition(1, 2));
      final s = await data.settings.get();
      expect((s.snoozeMinutes, s.buddyX, s.buddyY), (30, 1.0, 2.0));
    });
  });
}
