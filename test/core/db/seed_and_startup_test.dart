import 'package:clock/clock.dart';
import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/core/db/data_changes.dart';
import 'package:desk_buddy/core/db/seed/seed_data.dart';
import 'package:desk_buddy/core/db/seed/seeder.dart';
import 'package:desk_buddy/features/buddy/render/props.dart';
import 'package:desk_buddy/features/reminders/data/log_repository.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/reminders/domain/starter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  group('seed assets', () {
    late SeedData seed;
    setUpAll(() async => seed = await realSeed());

    test('four default categories with valid colors', () {
      expect(seed.categories.map((c) => c.name), [
        'Health',
        'Work',
        'Breaks',
        'Personal',
      ]);
      for (final c in seed.categories) {
        expect(c.colorHex, matches(RegExp(r'^#[0-9A-F]{6}$')));
      }
    });

    test('all seven prototype starters parse with sane fields', () {
      expect(seed.starters, hasLength(7));
      final hm = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
      for (final s in seed.starters) {
        expect(s.title, isNotEmpty);
        expect(
          propRegistry.containsKey(s.propId) || s.propId == 'default',
          isTrue,
          reason: '${s.title}: unknown prop ${s.propId}',
        );
        expect(s.timeOfDay, matches(hm));
        if (s.scheduleType == ScheduleType.interval) {
          expect(s.everyMinutes, greaterThanOrEqualTo(1));
          expect(s.activeFrom, matches(hm));
          expect(s.activeTo, matches(hm));
        }
        expect(s.daysOfWeek.every((d) => d >= 0 && d <= 6), isTrue);
        expect(s.dailyGoal, greaterThanOrEqualTo(0));
      }
    });
  });

  group('Seeder', () {
    late AppData data;
    late SeedData seed;
    setUp(() async {
      data = await memoryData();
      seed = await realSeed();
    });
    tearDown(() => data.close());

    test('seeds categories and the first three starters', () async {
      expect(await data.seeder.seedIfEmpty(seed), isTrue);
      final cats = await data.categories.all();
      expect(cats.map((c) => c.name), [
        'Health',
        'Work',
        'Breaks',
        'Personal',
      ]);
      final rs = await data.reminders.all();
      expect(rs.map((r) => r.title), [
        for (final s in seed.starters.take(initialStarterCount)) s.title,
      ]);
      for (final (i, r) in rs.indexed) {
        final s = seed.starters[i];
        expect(cats.firstWhere((c) => c.id == r.categoryId).name, s.category);
        expect(r.messageTemplate, s.messageTemplate);
        expect(r.dailyGoal, s.dailyGoal);
        expect(r.propId, s.propId);
        expect(r.enabled, isTrue);
        expect(r.nextDueAt, isNull, reason: 'the scheduler fills it in');
      }
    });

    test('is idempotent', () async {
      await data.seeder.seedIfEmpty(seed);
      expect(await data.seeder.seedIfEmpty(seed), isFalse);
      expect(await data.categories.all(), hasLength(4));
      expect(await data.reminders.all(), hasLength(3));
    });

    test('does nothing if the user already has categories', () async {
      await data.categories.create(name: 'Mine');
      expect(await data.seeder.seedIfEmpty(seed), isFalse);
      expect(await data.reminders.all(), isEmpty);
    });

    test('a starter whose category is missing creates it', () async {
      await data.categories.create(name: 'Work');
      final r = await data.seeder.reminderFromStarter(
        const Starter(title: 'Plant care', category: 'Garden'),
      );
      final cat = await data.categories.byId(r.categoryId);
      expect(cat!.name, 'Garden');
      expect(await data.reminders.all(), isEmpty, reason: 'not saved');
    });
  });

  group('resetEverything', () {
    test('back to defaults, seeded again, every topic announced', () async {
      final data = await memoryData();
      addTearDown(data.close);
      await data.prepare(await realSeed());
      await data.categories.create(name: 'Extra');
      await data.log.add(
        const LogEntry(id: 'l', at: 1, action: LogAction.done),
      );
      await data.settings.update((s) => s.copyWith(userName: 'Sam'));
      final topics = <Set<DataTopic>>[];
      data.changes.stream.listen(topics.add);

      await data.resetEverything(await realSeed());

      expect(await data.categories.all(), hasLength(4));
      expect(await data.reminders.all(), hasLength(3));
      expect(await data.log.since(0), isEmpty);
      expect((await data.settings.get()).userName, 'there');
      expect(topics.last, DataTopic.values.toSet());
    });
  });

  group('startup', () {
    test('prepare seeds once and prunes logs past retention', () async {
      final data = await memoryData();
      addTearDown(data.close);
      final cutoff = retentionCutoff(testNow);
      await data.log.addAll([
        LogEntry(id: 'old', at: cutoff - 1, action: LogAction.done),
        LogEntry(id: 'kept', at: cutoff, action: LogAction.done),
      ]);
      await data.prepare(await realSeed());
      await data.prepare(await realSeed());
      expect((await data.log.since(0)).map((l) => l.id), ['kept']);
      expect(await data.reminders.all(), hasLength(3));
    });

    test('retention cutoff is local midnight 90 days back, DST-proof', () {
      final cutoff = DateTime.fromMillisecondsSinceEpoch(
        retentionCutoff(DateTime(2026, 10, 6, 15, 30)),
      );
      expect(cutoff, DateTime(2026, 7, 8));
      expect((cutoff.hour, cutoff.minute), (0, 0));
      expect(logRetentionDays, 90);
    });

    test('prepare seeds with the injected clock', () async {
      final data = AppData(
        (await memoryData()).db,
        clock: Clock.fixed(DateTime(2030)),
      );
      addTearDown(data.close);
      await data.prepare(await realSeed());
      final first = (await data.reminders.all()).first;
      expect(first.createdAt, DateTime(2030).millisecondsSinceEpoch);
    });
  });
}
