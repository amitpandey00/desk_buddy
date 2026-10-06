import 'package:desk_buddy/app/dashboard_app.dart';
import 'package:desk_buddy/core/window/window_bus.dart';
import 'package:desk_buddy/features/dashboard/ui/dashboard_page.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/dashboard_harness.dart';

void main() {
  group('every page renders without layout errors', () {
    for (final section in DashboardSection.values) {
      for (final size in const [Size(1280, 900), Size(640, 900)]) {
        testWidgets('${section.name} at ${size.width.toInt()} px', (
          tester,
        ) async {
          final h = await DashboardHarness.create(tester);
          await h.pump(tester, size: size, section: section);
          expect(tester.takeException(), isNull);
          // The nav item ("🧑  Character") is always on screen.
          expect(find.textContaining(section.label), findsWidgets);
        });
      }
    }
  });

  group('dashboard goal rows', () {
    testWidgets('one row per goal reminder with count, goal and +1', (
      tester,
    ) async {
      final h = await DashboardHarness.create(tester);
      await h.pump(tester);
      // Seed: two of the three starters have goals.
      expect(find.byType(GoalRow), findsNWidgets(2));
      final goalRows = tester.widgetList<GoalRow>(find.byType(GoalRow));
      expect(goalRows.map((g) => g.reminder.dailyGoal), [8, 6]);
      expect(find.text('0 / 8 glasses'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('+1 logs a manual entry and updates count, bar and ring', (
      tester,
    ) async {
      final h = await DashboardHarness.create(tester);
      await h.pump(tester);
      await tester.tap(find.bySemanticsLabel('Add one to Drink water'));
      await h.settle(tester);
      final log = await h.db(tester, (d) => d.log.since(0));
      expect(log.single.manual, isTrue);
      expect(log.single.action, LogAction.done);
      expect(find.text('1 / 8 glasses'), findsOneWidget);
      // Ring: 1 of (8 + 6) goals = 7%.
      expect(find.text('7%'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.descendant(
          of: find.byType(GoalRow).first,
          matching: find.byType(LinearProgressIndicator),
        ),
      );
      expect(bar.value, closeTo(1 / 8, 1e-9));
      // And it shows in Today as "logged".
      expect(find.text('logged'), findsOneWidget);
    });

    testWidgets('no goals → empty state that opens Reminders', (tester) async {
      final h = await DashboardHarness.create(tester);
      await h.db(tester, (d) async {
        for (final r in await d.reminders.all()) {
          await d.reminders.save(r.copyWith(dailyGoal: 0));
        }
      });
      await h.pump(tester);
      expect(find.byType(GoalRow), findsNothing);
      await tester.tap(find.text('Set a goal'));
      await h.settle(tester);
      expect(find.text('Your reminders'), findsOneWidget);
    });

    testWidgets('Preview asks the overlay to pop the next reminder', (
      tester,
    ) async {
      final h = await DashboardHarness.create(tester);
      await h.pump(tester);
      await tester.tap(find.text('Preview next reminder'));
      await h.settle(tester);
      expect(h.bus.calls.single.$1, WindowBus.testReminderMethod);
    });
  });

  group('reminder editor validation', () {
    Future<DashboardHarness> openEditor(WidgetTester tester) async {
      final h = await DashboardHarness.create(tester);
      await h.pump(tester, section: DashboardSection.reminders);
      return h;
    }

    Future<void> save(WidgetTester tester, DashboardHarness h) async {
      final button = find.widgetWithText(FilledButton, 'Add reminder');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await h.settle(tester);
    }

    testWidgets('empty title → "Give the reminder a title"', (tester) async {
      final h = await openEditor(tester);
      await save(tester, h);
      expect(find.text('Give the reminder a title'), findsOneWidget);
      expect(await h.db(tester, (d) => d.reminders.all()), hasLength(3));
    });

    Future<void> chooseOnce(WidgetTester tester, DashboardHarness h) async {
      final repeat = find.widgetWithText(
        DropdownButtonFormField<ScheduleType>,
        'Repeat',
      );
      await tester.ensureVisible(repeat);
      await tester.tap(repeat);
      await h.settle(tester);
      await tester.tap(find.text('Just once').last);
      await h.settle(tester);
    }

    testWidgets('one-off without a date → "Pick a date…"', (tester) async {
      final h = await openEditor(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'Dentist',
      );
      await chooseOnce(tester, h);
      await save(tester, h);
      expect(find.text('Pick a date for a one-time reminder'), findsOneWidget);
    });

    testWidgets('valid reminder saves, schedules and resets the form', (
      tester,
    ) async {
      final h = await openEditor(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Title'),
        'Call home',
      );
      await save(tester, h);
      expect(find.text('Added “Call home”'), findsOneWidget);
      final all = await h.db(tester, (d) => d.reminders.all());
      final added = all.singleWhere((r) => r.title == 'Call home');
      expect(added.nextDueAt, isNotNull);
      expect(added.messageTemplate, 'Hey, {name}! ');
    });

    testWidgets('typing survives a data refresh (e.g. a reminder fires)', (
      tester,
    ) async {
      final h = await openEditor(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Dent');
      // Something else changes the reminders table meanwhile.
      await h.db(tester, (d) async {
        final first = (await d.reminders.all()).first;
        await d.reminders.setSchedule(first.id, nextDueAt: 42);
      });
      await h.settle(tester);
      final title = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Title'),
      );
      expect(title.controller!.text, 'Dent');
    });

    testWidgets('saving an edit keeps on/off as it is now (no re-enable)', (
      tester,
    ) async {
      final h = await openEditor(tester);
      final first = (await h.db(tester, (d) => d.reminders.all())).first;
      final edit = find.widgetWithText(OutlinedButton, 'Edit').first;
      await tester.ensureVisible(edit);
      await tester.tap(edit);
      await h.settle(tester);
      // Switched off in the list after Edit was opened.
      await h.db(tester, (d) async {
        final r = (await d.reminders.byId(first.id))!;
        await d.reminders.save(r.copyWith(enabled: false, nextDueAt: null));
      });
      await h.settle(tester);
      final save = find.widgetWithText(FilledButton, 'Save changes');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await h.settle(tester);
      final after = await h.db(tester, (d) => d.reminders.byId(first.id));
      expect(after!.enabled, isFalse);
      expect(after.nextDueAt, isNull);
    });

    testWidgets('a starter chip fills the form without saving', (
      tester,
    ) async {
      final h = await openEditor(tester);
      await tester.tap(find.text('📖 Read 10 pages'));
      await h.settle(tester);
      final title = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Title'),
      );
      expect(title.controller!.text, 'Read 10 pages');
      expect(await h.db(tester, (d) => d.reminders.all()), hasLength(3));
    });
  });
}
