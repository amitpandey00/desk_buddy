import 'dart:math';

import 'package:desk_buddy/app/providers.dart';
import 'package:desk_buddy/app/theme.dart';
import 'package:desk_buddy/core/clock/clock_provider.dart';
import 'package:desk_buddy/core/db/providers.dart';
import 'package:desk_buddy/features/analytics/domain/week_analytics.dart';
import 'package:desk_buddy/features/categories/domain/category.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/goals.dart';
import 'package:desk_buddy/shared/color_hex.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:desk_buddy/shared/widgets/ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _otherColor = Color(0xFF94A3B8);

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  String? _goalId;

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersProvider).value ?? const [];
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final week = ref.watch(weekLogProvider).value ?? const [];
    final history = ref.watch(streakLogProvider).value ?? const [];
    final hasSamples = ref.watch(hasSampleHistoryProvider).value ?? false;
    final wc = ref.watch(wallClockProvider);
    final now = ref.read(appClockProvider).now().millisecondsSinceEpoch;
    final a = WeekAnalytics.compute(
      reminders: reminders,
      categories: categories,
      log: week,
      now: now,
      wallClock: wc,
    );
    final goals = reminders.where((r) => r.dailyGoal > 0).toList();
    final goal =
        goals.where((r) => r.id == _goalId).firstOrNull ?? goals.firstOrNull;

    final header = PageHeader(
      Strings.navAnalytics,
      subtitle: Text(
        hasSamples
            ? Strings.analyticsSubtitleSample
            : Strings.analyticsSubtitle,
      ),
    );

    if (a.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const Panel(
            title: Strings.noDataTitle,
            child: Text(Strings.noDataBody),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        LayoutBuilder(
          builder: (context, c) {
            final kpis = [
              _Kpi('${a.completionPercent}%', Strings.kpiRate),
              _Kpi(
                Strings.countdownSeconds(a.averageResponseSeconds),
                Strings.kpiResponse,
              ),
              _Kpi(
                '${a.done}',
                Strings.kpiCompleted(a.snoozed, a.skipped, a.missed),
              ),
            ];
            return c.maxWidth < 640
                ? Column(
                    children: [
                      for (final k in kpis)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: k,
                        ),
                    ],
                  )
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, k) in kpis.indexed) ...[
                          if (i > 0) const SizedBox(width: 18),
                          Expanded(child: k),
                        ],
                      ],
                    ),
                  );
          },
        ),
        const SizedBox(height: 18),
        TwoColumns(
          leftFlex: 1,
          rightFlex: 1,
          left: Panel(
            title: Strings.completedPerDay,
            child: _StackedDays(analytics: a, categories: categories),
          ),
          right: Panel(
            title: Strings.goalProgressTitle,
            trailing: goals.length > 1
                ? DropdownButton<String>(
                    value: goal!.id,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final r in goals)
                        DropdownMenuItem(
                          value: r.id,
                          child: Text(
                            '${r.emoji} ${r.title}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (id) => setState(() => _goalId = id),
                  )
                : null,
            child: goal == null
                ? Text(
                    Strings.goalChartEmpty,
                    style: TextStyle(color: context.desk.muted),
                  )
                : _GoalLine(
                    reminder: goal,
                    series: goalSeries(goal, week, a.dayStarts, wc),
                    dayStarts: a.dayStarts,
                    color: colorFromHex(
                      categoryFor(categories, goal.categoryId).colorHex,
                    ),
                    streak: streak(history, goal, now, wc),
                  ),
          ),
        ),
        const SizedBox(height: 18),
        Panel(title: Strings.byReminder, child: _ByReminder(a.perReminder)),
        const SizedBox(height: 18),
        Panel(
          title: Strings.whenYouRespond,
          child: _Hours(a.completedByHour),
        ),
        if (hasSamples) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(logRepositoryProvider).deleteSamples();
                if (context.mounted) {
                  showToast(context, Strings.sampleRemoved);
                }
              },
              child: const Text(Strings.removeSample),
            ),
          ),
        ],
      ],
    );
  }
}

String _weekday(int dayStart) =>
    Strings.dayShort[DateTime.fromMillisecondsSinceEpoch(dayStart).weekday % 7];

class _Kpi extends StatelessWidget {
  const _Kpi(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Semantics(
        label: '$value $label',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: displayFont,
                fontWeight: FontWeight.w800,
                fontSize: 34,
                height: 1,
                color: context.desk.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: context.desk.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

class _StackedDays extends StatelessWidget {
  const _StackedDays({required this.analytics, required this.categories});

  final WeekAnalytics analytics;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final a = analytics;
    final c = context.desk;
    final used = a.usedCategoryKeys;
    Color colorOf(String? key) => key == null
        ? _otherColor
        : colorFromHex(categoryFor(categories, key).colorHex);
    String nameOf(String? key) =>
        key == null ? Strings.other : categoryFor(categories, key).name;
    final order = [
      for (final cat in categories)
        if (used.contains(cat.id)) cat.id,
      if (used.contains(null)) null,
    ];
    final maxY = max(4, a.maxCompletedInADay).toDouble();
    int total(int i) => a.completedPerDay[i].values.fold(0, (x, y) => x + y);
    final summary = [
      for (final (i, d) in a.dayStarts.indexed) '${_weekday(d)}: ${total(i)}',
    ].join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: Strings.chartPerDayLabel(summary),
          excludeSemantics: true,
          child: SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          _weekday(a.dayStarts[v.toInt()]),
                          style: TextStyle(fontSize: 12, color: c.muted),
                        ),
                      ),
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                      rod.toY.toInt().toString(),
                      const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < 7; i++)
                    () {
                      var y = 0.0;
                      final stack = <BarChartRodStackItem>[];
                      for (final key in order) {
                        final v = (a.completedPerDay[i][key] ?? 0).toDouble();
                        if (v == 0) continue;
                        stack.add(BarChartRodStackItem(y, y + v, colorOf(key)));
                        y += v;
                      }
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: y,
                            width: 26,
                            color: Colors.transparent,
                            rodStackItems: stack,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      );
                    }(),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            for (final key in order)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorOf(key),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    nameOf(key),
                    style: TextStyle(fontSize: 13, color: c.muted),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _GoalLine extends StatelessWidget {
  const _GoalLine({
    required this.reminder,
    required this.series,
    required this.dayStarts,
    required this.color,
    required this.streak,
  });

  final Reminder reminder;
  final List<int> series;
  final List<int> dayStarts;
  final Color color;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final goal = reminder.dailyGoal.toDouble();
    final top = max(goal + 2, series.fold<int>(0, max).toDouble());
    final avg = series.fold(0, (a, b) => a + b) / 7;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: Strings.chartGoalLabel(
            reminder.title,
            [
              for (final (i, v) in series.indexed)
                '${_weekday(dayStarts[i])} $v',
            ].join(', '),
            reminder.dailyGoal,
          ),
          excludeSemantics: true,
          child: SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: top,
                minX: 0,
                maxX: 6,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          _weekday(dayStarts[v.toInt()]),
                          style: TextStyle(fontSize: 12, color: c.muted),
                        ),
                      ),
                    ),
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: goal,
                      color: c.coral,
                      dashArray: [6, 6],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: TextStyle(color: c.coral, fontSize: 12),
                        labelResolver: (_) =>
                            Strings.goalLineLabel(reminder.dailyGoal),
                      ),
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (final (i, v) in series.indexed)
                        FlSpot(i.toDouble(), v.toDouble()),
                    ],
                    color: color,
                    barWidth: 3.5,
                    dotData: FlDotData(
                      getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                        radius: 5,
                        color: c.panel,
                        strokeColor: color,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          Strings.goalFooter(avg, reminder.goalUnit, streak),
          style: TextStyle(fontSize: 12.5, color: c.muted),
        ),
      ],
    );
  }
}

class _ByReminder extends StatelessWidget {
  const _ByReminder(this.rows);
  final List<ReminderStats> rows;

  @override
  Widget build(BuildContext context) {
    DataCell num(String v) => DataCell(
      Align(alignment: Alignment.centerRight, child: Text(v)),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: TextStyle(
          color: context.desk.muted,
          fontWeight: FontWeight.w600,
        ),
        columns: const [
          DataColumn(label: Text(Strings.colReminder)),
          DataColumn(label: Text(Strings.colDone), numeric: true),
          DataColumn(label: Text(Strings.colSnoozed), numeric: true),
          DataColumn(label: Text(Strings.colSkipped), numeric: true),
          DataColumn(label: Text(Strings.colMissed), numeric: true),
          DataColumn(label: Text(Strings.colCompletion), numeric: true),
        ],
        rows: [
          for (final s in rows)
            DataRow(
              cells: [
                DataCell(Text('${s.reminder.emoji} ${s.reminder.title}')),
                num('${s.done}'),
                num('${s.snoozed}'),
                num('${s.skipped}'),
                num('${s.missed}'),
                num(
                  s.completionPercent == null
                      ? Strings.none
                      : '${s.completionPercent}%',
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Hours extends StatelessWidget {
  const _Hours(this.byHour);
  final List<int> byHour;

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final top = max(1, byHour.fold<int>(0, max));
    String hourLabel(int h) => Strings.hourShort(h);
    final any = byHour.any((v) => v > 0);
    return Semantics(
      // With no completions there is no busiest hour (indexOf would be -1).
      label: any
          ? Strings.chartHoursLabel(hourLabel(byHour.indexOf(top)))
          : Strings.chartHoursEmpty,
      excludeSemantics: true,
      child: SizedBox(
        height: 130,
        child: BarChart(
          BarChartData(
            maxY: top.toDouble(),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: const BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, meta) => v.toInt() % 3 == 0
                      ? SideTitleWidget(
                          meta: meta,
                          child: Text(
                            hourLabel(v.toInt()),
                            style: TextStyle(fontSize: 11, color: c.muted),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            barGroups: [
              for (var h = 0; h < 24; h++)
                BarChartGroupData(
                  x: h,
                  barRods: [
                    BarChartRodData(
                      toY: byHour[h].toDouble(),
                      width: 14,
                      borderRadius: BorderRadius.circular(2),
                      color: c.accent.withValues(
                        alpha: .25 + .75 * byHour[h] / top,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
