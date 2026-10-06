import 'dart:math';

import 'package:desk_buddy/app/dashboard_app.dart';
import 'package:desk_buddy/app/providers.dart';
import 'package:desk_buddy/app/theme.dart';
import 'package:desk_buddy/core/clock/clock_provider.dart';
import 'package:desk_buddy/core/db/providers.dart';
import 'package:desk_buddy/features/categories/domain/category.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/goals.dart';
import 'package:desk_buddy/shared/color_hex.dart';
import 'package:desk_buddy/shared/format/schedule_describe.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:desk_buddy/shared/widgets/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider).value ?? const [];
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final settings = ref.watch(settingsProvider).value;
    final today = ref.watch(todayLogProvider).value ?? const [];
    final history = ref.watch(streakLogProvider).value ?? const [];
    final wc = ref.watch(wallClockProvider);
    // Minute resolution is enough here (greeting, today's counts); the live
    // countdowns tick on their own, so the page doesn't rebuild every second.
    final minute = ref.watch(
      nowProvider.select(
        (v) => (v.value ?? 0) ~/ Duration.millisecondsPerMinute,
      ),
    );
    final now = minute == 0
        ? ref.read(appClockProvider).now().millisecondsSinceEpoch
        : minute * Duration.millisecondsPerMinute;

    final goals = reminders.where((r) => r.dailyGoal > 0).toList();
    final summary = goalSummary(goals, today, now, wc);
    final upcoming = upcomingOf(reminders);
    final hour = wc.toWall(now).hour;
    final name = settings?.userName ?? Strings.defaultUserName;
    final dnd = settings?.doNotDisturb ?? false;
    int count(LogAction a) => today.where((l) => l.action == a).length;

    final next = upcoming.firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          Strings.greeting(hour, name),
          subtitle: dnd
              ? const Text(Strings.dndNotice)
              : next == null
              ? const Text(Strings.noneScheduled)
              : Wrap(
                  children: [
                    Text(Strings.nextUp(next.emoji, next.title)),
                    LiveCountdown(
                      next.nextDueAt!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, c) {
                final ring = _GoalRing(
                  percent: summary.percent,
                  hasGoals: goals.isNotEmpty,
                );
                final body = _GoalsColumn(
                  goals: goals,
                  categories: categories,
                  today: today,
                  history: history,
                  now: now,
                  done: count(LogAction.done),
                  snoozed: count(LogAction.snoozed),
                  missed: count(LogAction.missed),
                  dnd: dnd,
                  previewTarget: next ?? reminders.firstOrNull,
                );
                return c.maxWidth < 560
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [ring, const SizedBox(height: 20), body],
                      )
                    : Row(
                        children: [
                          ring,
                          const SizedBox(width: 28),
                          Expanded(child: body),
                        ],
                      );
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
        TwoColumns(
          left: Panel(
            title: Strings.comingUp,
            child: upcoming.isEmpty
                ? const _Muted(Strings.addToStart)
                : Column(
                    children: [
                      for (final (i, r) in upcoming.take(5).indexed)
                        _ListRow(
                          first: i == 0,
                          leading: EmojiTile(
                            r.emoji,
                            colorHex: categoryFor(
                              categories,
                              r.categoryId,
                            ).colorHex,
                          ),
                          title: r.title,
                          subtitle: describeSchedule(r),
                          trailing: LiveCountdown(
                            r.nextDueAt!,
                            style: const TextStyle(
                              fontFamily: displayFont,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          right: Panel(
            title: Strings.todayTitle,
            child: today.isEmpty
                ? const _Muted(Strings.nothingYetToday)
                : Column(
                    children: [
                      for (final (i, e) in today.reversed.take(8).indexed)
                        _TodayRow(
                          entry: e,
                          reminder: reminders
                              .where((r) => r.id == e.reminderId)
                              .firstOrNull,
                          first: i == 0,
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.percent, required this.hasGoals});

  final int percent;
  final bool hasGoals;

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return Semantics(
      label: Strings.ringLabel(percent, hasGoals: hasGoals),
      child: ExcludeSemantics(
        child: SizedBox(
          width: 170,
          height: 170,
          child: CustomPaint(
            painter: _RingPainter(percent / 100, c.panel2, c.accent),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontFamily: displayFont,
                      fontWeight: FontWeight.w800,
                      fontSize: 44,
                      height: 1,
                      color: c.ink,
                    ),
                  ),
                  Text(
                    hasGoals ? Strings.ofTodaysGoals : Strings.noGoalsSet,
                    style: TextStyle(fontSize: 12.5, color: c.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.fraction, this.track, this.fill);
  final double fraction;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(13);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * size.width / 160;
    canvas.drawArc(r, 0, 2 * pi, false, p..color = track);
    if (fraction > 0) {
      canvas.drawArc(
        r,
        -pi / 2,
        2 * pi * fraction.clamp(0, 1),
        false,
        p
          ..color = fill
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.fill != fill || old.track != track;
}

class _GoalsColumn extends ConsumerWidget {
  const _GoalsColumn({
    required this.goals,
    required this.categories,
    required this.today,
    required this.history,
    required this.now,
    required this.done,
    required this.snoozed,
    required this.missed,
    required this.dnd,
    required this.previewTarget,
  });

  final List<Reminder> goals;
  final List<Category> categories;
  final List<LogEntry> today;
  final List<LogEntry> history;
  final int now;
  final int done;
  final int snoozed;
  final int missed;
  final bool dnd;
  final Reminder? previewTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.desk;
    final wc = ref.watch(wallClockProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.todaysGoals,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (goals.isEmpty) ...[
          const _Muted(Strings.goalsEmpty),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => ref
                .read(currentSectionProvider.notifier)
                .go(DashboardSection.reminders),
            child: const Text(Strings.setAGoal),
          ),
        ] else
          for (final (i, r) in goals.indexed)
            GoalRow(
              reminder: r,
              count: countToday(today, r.id, now, wc),
              streak: streak(history, r, now, wc),
              colorHex: categoryFor(categories, r.categoryId).colorHex,
              first: i == 0,
            ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 26,
          runSpacing: 8,
          children: [
            _Fact(done, Strings.completedToday),
            _Fact(snoozed, Strings.snoozedLabel),
            _Fact(missed, Strings.missedLabel),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () async {
                final target = previewTarget;
                if (target == null) {
                  showToast(context, Strings.nothingToPreview);
                  return;
                }
                await ref.read(windowBusProvider).testReminder(target.id);
              },
              child: const Text(Strings.previewNext),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: dnd,
                  activeTrackColor: c.mint,
                  onChanged: (v) => ref
                      .read(settingsRepositoryProvider)
                      .update((s) => s.copyWith(doNotDisturb: v)),
                ),
                const SizedBox(width: 8),
                const Text(
                  Strings.doNotDisturb,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// One "Today's goals" row: tile, title, count/goal, streak, bar, +1.
class GoalRow extends ConsumerWidget {
  const GoalRow({
    required this.reminder,
    required this.count,
    required this.streak,
    required this.colorHex,
    this.first = false,
    super.key,
  });

  final Reminder reminder;
  final int count;
  final int streak;
  final String colorHex;
  final bool first;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.desk;
    final r = reminder;
    final color = colorFromHex(colorHex);
    return _Divided(
      first: first,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            EmojiTile(r.emoji, colorHex: colorHex),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    Strings.goalLine(count, r.dailyGoal, r.goalUnit, streak),
                    style: TextStyle(fontSize: 13, color: c.muted),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: (count / r.dailyGoal).clamp(0, 1),
                      minHeight: 8,
                      color: color,
                      backgroundColor: c.panel2,
                      // The value must stay numeric (a percentage) for
                      // screen readers; the count goes in the label.
                      semanticsLabel: Strings.goalBarLabel(
                        r.title,
                        count,
                        r.dailyGoal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Semantics(
              label: Strings.addOneTo(r.title),
              button: true,
              excludeSemantics: true,
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(reminderCommandsProvider).logManual(r);
                  if (context.mounted) {
                    showToast(
                      context,
                      Strings.plusOneToast(r.emoji, r.goalUnit),
                    );
                  }
                },
                child: const Text(Strings.plusOne),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({
    required this.entry,
    required this.reminder,
    required this.first,
  });

  final LogEntry entry;
  final Reminder? reminder;
  final bool first;

  @override
  Widget build(BuildContext context) => _Divided(
    first: first,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              TimeOfDay.fromDateTime(
                DateTime.fromMillisecondsSinceEpoch(entry.at),
              ).format(context),
              style: TextStyle(color: context.desk.muted, fontSize: 13.5),
            ),
          ),
          Expanded(
            child: Text(
              reminder == null
                  ? Strings.deletedReminder
                  : '${reminder!.emoji} ${reminder!.title}',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5),
            ),
          ),
          StatusTag(entry),
        ],
      ),
    ),
  );
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.first,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final bool first;
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) => _Divided(
    first: first,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: context.desk.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    ),
  );
}

class _Divided extends StatelessWidget {
  const _Divided({required this.first, required this.child});
  final bool first;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: first ? null : Border(top: BorderSide(color: context.desk.line)),
    ),
    child: child,
  );
}

class _Fact extends StatelessWidget {
  const _Fact(this.value, this.label);
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$value',
        style: TextStyle(
          fontFamily: displayFont,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          height: 1.1,
          color: context.desk.ink,
        ),
      ),
      Text(label, style: TextStyle(fontSize: 13, color: context.desk.muted)),
    ],
  );
}

class _Muted extends StatelessWidget {
  const _Muted(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(color: context.desk.muted));
}
