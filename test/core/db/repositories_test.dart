import 'package:desk_buddy/core/db/app_data.dart';
import 'package:desk_buddy/core/db/data_changes.dart';
import 'package:desk_buddy/features/categories/domain/category.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';

void main() {
  late AppData data;
  late List<Set<DataTopic>> changes;

  setUp(() async {
    data = await memoryData();
    changes = [];
    data.changes.stream.listen(changes.add);
  });
  tearDown(() => data.close());

  group('CategoryRepository', () {
    test('create appends in sort order', () async {
      final a = await data.categories.create(name: 'A');
      final b = await data.categories.create(name: 'B');
      expect((a.sortOrder, b.sortOrder), (0, 1));
      expect((await data.categories.all()).map((c) => c.name), ['A', 'B']);
      expect(changes, everyElement({DataTopic.categories}));
    });

    test('findOrCreateByName is case-insensitive and creates once', () async {
      final h = await data.categories.create(name: 'Health');
      expect((await data.categories.findOrCreateByName(' health ')).id, h.id);
      final made = await data.categories.findOrCreateByName('Hobbies');
      expect(made.emoji, isNotEmpty);
      expect(await data.categories.findOrCreateByName('HOBBIES'), made);
      expect(await data.categories.all(), hasLength(2));
    });

    test('delete moves reminders to the first remaining category', () async {
      final a = await data.categories.create(name: 'A');
      final b = await data.categories.create(name: 'B');
      final c = await data.categories.create(name: 'C');
      await data.reminders.saveAll([
        reminder('r1', b.id),
        reminder('r2', c.id),
      ]);
      await data.categories.delete(b.id);
      expect((await data.reminders.byId('r1'))!.categoryId, a.id);
      expect((await data.reminders.byId('r2'))!.categoryId, c.id);
      expect(changes.last, {DataTopic.categories, DataTopic.reminders});
    });

    test('cannot delete the last category', () async {
      final only = await data.categories.create(name: 'Only');
      await expectLater(
        data.categories.delete(only.id),
        throwsA(isA<LastCategoryException>()),
      );
      expect(await data.categories.all(), hasLength(1));
    });

    test('update renames, recolors and re-emojis', () async {
      final c = await data.categories.create(name: 'A');
      await data.categories.update(
        c.copyWith(name: 'Z', emoji: '🎯', colorHex: '#000000'),
      );
      expect(
        await data.categories.byId(c.id),
        c.copyWith(name: 'Z', emoji: '🎯', colorHex: '#000000'),
      );
    });
  });

  group('ReminderRepository', () {
    late Category cat;
    setUp(() async => cat = await data.categories.create(name: 'A'));

    test('round-trips every field', () async {
      final r = Reminder(
        id: 'r1',
        title: 'Call home',
        categoryId: cat.id,
        createdAt: 5,
        updatedAt: 5,
        emoji: '📞',
        messageTemplate: '{name}, call!',
        scheduleType: ScheduleType.daily,
        everyMinutes: 30,
        activeFrom: '22:00',
        activeTo: '02:00',
        timeOfDay: '19:30',
        daysOfWeek: [5, 1, 3],
        date: '2026-12-24',
        dailyGoal: 2,
        goalUnit: 'calls',
        propId: 'phone',
        doneLabel: 'Calling',
        enabled: false,
        nextDueAt: 123,
      );
      final saved = await data.reminders.save(r);
      expect(saved.updatedAt, testNow.millisecondsSinceEpoch);
      // Days come back sorted.
      expect(
        await data.reminders.byId('r1'),
        saved.copyWith(daysOfWeek: [1, 3, 5]),
      );
    });

    test('saving null clears a column (regression)', () async {
      await data.reminders.save(
        reminder('r', cat.id).copyWith(
          activeFrom: '08:00',
          activeTo: '22:00',
          date: '2026-12-24',
          nextDueAt: 5,
        ),
      );
      final r = (await data.reminders.byId('r'))!;
      await data.reminders.save(
        r.copyWith(
          activeFrom: null,
          activeTo: null,
          date: null,
          nextDueAt: null,
        ),
      );
      final cleared = (await data.reminders.byId('r'))!;
      expect(
        (cleared.activeFrom, cleared.activeTo, cleared.date, cleared.nextDueAt),
        (null, null, null, null),
      );
      await data.reminders.saveAll([cleared.copyWith(date: '2027-01-01')]);
      await data.reminders.saveAll([cleared]);
      expect((await data.reminders.byId('r'))!.date, isNull);
    });

    test('updatedAt only grows, even if the clock goes back', () async {
      final saved = await data.reminders.save(
        reminder('r', cat.id).copyWith(
          updatedAt: testNow.millisecondsSinceEpoch + 60000,
        ),
      );
      // The repository's clock (testNow) is now *behind* the row.
      expect(saved.updatedAt, testNow.millisecondsSinceEpoch + 60001);
    });

    test('lists in creation order', () async {
      await data.reminders.saveAll([
        reminder('b', cat.id, createdAt: 2),
        reminder('a', cat.id, createdAt: 1),
      ]);
      expect((await data.reminders.all()).map((r) => r.id), ['a', 'b']);
    });

    test('setSchedule touches only scheduling columns', () async {
      await data.reminders.save(reminder('r', cat.id, title: 'Before'));
      final edited = (await data.reminders.byId('r'))!.copyWith(
        title: 'Edited elsewhere',
      );
      await data.reminders.save(edited);
      await data.reminders.setSchedule('r', nextDueAt: 999, enabled: false);
      final r = (await data.reminders.byId('r'))!;
      expect(
        (r.title, r.nextDueAt, r.enabled),
        ('Edited elsewhere', 999, false),
      );
      await data.reminders.setSchedule('r');
      expect((await data.reminders.byId('r'))!.nextDueAt, isNull);
      expect((await data.reminders.byId('r'))!.enabled, isFalse);
    });

    test('deleting a reminder keeps its history', () async {
      await data.reminders.save(reminder('r', cat.id));
      await data.log.add(
        const LogEntry(id: 'l', at: 1, action: LogAction.done, reminderId: 'r'),
      );
      await data.reminders.delete('r');
      expect(await data.reminders.all(), isEmpty);
      expect((await data.log.since(0)).single.reminderId, 'r');
    });

    test('watchAll emits on change', () async {
      final seen = data.reminders.watchAll().map((l) => l.length);
      final expectation = expectLater(seen, emitsInOrder([0, 1]));
      await pumpEventQueue();
      await data.reminders.save(reminder('r', cat.id));
      await expectation;
    });
  });

  group('LogRepository', () {
    LogEntry e(String id, int at, {bool sample = false, String? rid}) =>
        LogEntry(
          id: id,
          at: at,
          action: LogAction.done,
          sample: sample,
          reminderId: rid,
        );

    test('since filters by time and reminder, oldest first', () async {
      await data.log.addAll([
        e('3', 30, rid: 'x'),
        e('1', 10, rid: 'x'),
        e('2', 20, rid: 'y'),
      ]);
      expect((await data.log.since(15)).map((l) => l.id), ['2', '3']);
      expect(
        (await data.log.since(0, reminderId: 'x')).map((l) => l.id),
        ['1', '3'],
      );
    });

    test('pruneBefore removes older rows only', () async {
      await data.log.addAll([e('old', 10), e('edge', 20), e('new', 30)]);
      expect(await data.log.pruneBefore(20), 1);
      expect((await data.log.since(0)).map((l) => l.id), ['edge', 'new']);
    });

    test('sample rows can be detected and removed', () async {
      await data.log.addAll([e('real', 1), e('fake', 2, sample: true)]);
      expect(await data.log.watchHasSamples().first, isTrue);
      expect(await data.log.deleteSamples(), 1);
      expect(await data.log.watchHasSamples().first, isFalse);
      expect((await data.log.since(0)).single.id, 'real');
    });

    test('all three actions and flags round-trip', () async {
      const entry = LogEntry(
        id: 'x',
        at: 7,
        action: LogAction.snoozed,
        reminderId: 'r',
        categoryId: 'c',
        responseSeconds: 42,
        manual: true,
      );
      await data.log.add(entry);
      expect((await data.log.since(0)).single, entry);
    });
  });
}
