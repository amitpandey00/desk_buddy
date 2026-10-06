import 'package:desk_buddy/app/providers.dart';
import 'package:desk_buddy/app/theme.dart';
import 'package:desk_buddy/core/clock/clock_provider.dart';
import 'package:desk_buddy/core/db/providers.dart';
import 'package:desk_buddy/features/buddy/render/props.dart';
import 'package:desk_buddy/features/categories/domain/category.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/scheduler/engine/schedule.dart';
import 'package:desk_buddy/shared/format/schedule_describe.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:desk_buddy/shared/widgets/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Add / edit form (prototype `#rform`). Saving validates through
/// `ReminderCommands`, which also schedules from now.
class ReminderEditor extends ConsumerStatefulWidget {
  const ReminderEditor({
    required this.initial,
    required this.isNew,
    required this.categories,
    required this.onDone,
    super.key,
  });

  final Reminder initial;
  final bool isNew;
  final List<Category> categories;
  final VoidCallback onDone;

  @override
  ConsumerState<ReminderEditor> createState() => _ReminderEditorState();
}

class _ReminderEditorState extends ConsumerState<ReminderEditor> {
  late final Reminder r = widget.initial;
  late final _title = TextEditingController(text: r.title);
  late final _emoji = TextEditingController(text: r.emoji);
  late final _message = TextEditingController(text: r.messageTemplate);
  late final _every = TextEditingController(text: '${r.everyMinutes}');
  late final _goal = TextEditingController(text: '${r.dailyGoal}');
  late final _unit = TextEditingController(text: r.goalUnit);
  late final _doneLabel = TextEditingController(text: r.doneLabel);
  final _titleFocus = FocusNode();

  late String _categoryId = r.categoryId;
  late String _propId = r.propId;
  late ScheduleType _type = r.scheduleType;
  late String _activeFrom = r.activeFrom ?? '09:00';
  late String _activeTo = r.activeTo ?? '21:00';
  late bool _allDay =
      r.scheduleType == ScheduleType.interval &&
      (r.activeFrom == null || r.activeTo == null) &&
      !widget.isNew;
  late String _time = r.timeOfDay;
  late final Set<int> _days = {...r.daysOfWeek};
  late String? _date = r.date;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _title,
      _emoji,
      _message,
      _every,
      _goal,
      _unit,
      _doneLabel,
    ]) {
      c.dispose();
    }
    _titleFocus.dispose();
    super.dispose();
  }

  Reminder _build() => r.copyWith(
    title: _title.text,
    emoji: _emoji.text.trim().isEmpty
        ? Strings.defaultReminderEmoji
        : _emoji.text.trim(),
    messageTemplate: _message.text,
    categoryId: _categoryId,
    propId: _propId,
    scheduleType: _type,
    everyMinutes: int.tryParse(_every.text.trim()) ?? 60,
    activeFrom: _type == ScheduleType.interval && !_allDay ? _activeFrom : null,
    activeTo: _type == ScheduleType.interval && !_allDay ? _activeTo : null,
    timeOfDay: _time,
    daysOfWeek: _type == ScheduleType.daily ? (_days.toList()..sort()) : [],
    date: _type == ScheduleType.once ? _date : null,
    dailyGoal: int.tryParse(_goal.text.trim()) ?? 0,
    goalUnit: _unit.text,
    doneLabel: _doneLabel.text.trim().isEmpty
        ? Strings.defaultDoneLabel
        : _doneLabel.text.trim(),
  );

  Future<void> _save() async {
    final commands = ref.read(reminderCommandsProvider);
    var candidate = _build();
    if (!widget.isNew) {
      // The form only owns its own fields. On/off may have changed in the
      // list since Edit was clicked; take that from the current row (D22).
      final current = await ref
          .read(reminderRepositoryProvider)
          .byId(candidate.id);
      if (!mounted) return;
      if (current == null) {
        showToast(context, Strings.reminderGone);
        widget.onDone();
        return;
      }
      candidate = candidate.copyWith(
        enabled: current.enabled,
        createdAt: current.createdAt,
        updatedAt: current.updatedAt,
        source: current.source,
      );
    }
    final problem = commands.validate(candidate);
    if (problem != null) {
      showToast(context, problem.message);
      if (candidate.title.trim().isEmpty) _titleFocus.requestFocus();
      return;
    }
    setState(() => _saving = true);
    final saved = await commands.save(candidate);
    if (!mounted) return;
    setState(() => _saving = false);
    showToast(
      context,
      widget.isNew ? Strings.added(saved.title) : Strings.changesSaved,
    );
    widget.onDone();
  }

  Future<void> _pickTime(String current, ValueChanged<String> set) async {
    final m = parseHm(current) ?? 9 * 60;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: m ~/ 60, minute: m % 60),
    );
    if (t != null) {
      set(
        '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}',
      );
    }
  }

  Future<void> _pickDate() async {
    final now = ref.read(appClockProvider).now();
    final today = DateTime(now.year, now.month, now.day);
    final d = parseDate(_date);
    final stored = d == null ? today : DateTime(d.$1, d.$2, d.$3);
    final picked = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: DateTime(now.year + 5),
      // A one-off that already fired has a past date; the picker can't
      // start before firstDate.
      initialDate: stored.isBefore(today) ? today : stored,
    );
    if (picked != null) {
      setState(
        () => _date =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-'
            '${picked.day.toString().padLeft(2, '0')}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    Widget pair(Widget a, Widget b) => LayoutBuilder(
      builder: (context, box) => box.maxWidth < 420
          ? Column(children: [a, const SizedBox(height: 12), b])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: a),
                const SizedBox(width: 12),
                Expanded(child: b),
              ],
            ),
    );
    Widget section(String legend, List<Widget> children) => InputDecorator(
      decoration: InputDecoration(
        labelText: legend,
        filled: false,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, w) in children.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            w,
          ],
        ],
      ),
    );

    return FocusTraversalGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pair(
            TextField(
              controller: _title,
              focusNode: _titleFocus,
              decoration: const InputDecoration(
                labelText: Strings.fieldTitle,
                hintText: Strings.titleHint,
              ),
              textInputAction: TextInputAction.next,
            ),
            TextField(
              controller: _emoji,
              decoration: const InputDecoration(labelText: Strings.fieldIcon),
              inputFormatters: [LengthLimitingTextInputFormatter(4)],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _message,
            decoration: const InputDecoration(
              labelText: Strings.fieldMessage,
              helperText: Strings.messageHint,
              helperMaxLines: 2,
            ),
          ),
          const SizedBox(height: 12),
          pair(
            DropdownButtonFormField<String>(
              initialValue: widget.categories.any((x) => x.id == _categoryId)
                  ? _categoryId
                  : null,
              decoration: const InputDecoration(
                labelText: Strings.fieldCategory,
              ),
              items: [
                for (final cat in widget.categories)
                  DropdownMenuItem(
                    value: cat.id,
                    child: Text('${cat.emoji} ${cat.name}'),
                  ),
              ],
              onChanged: (v) => setState(() => _categoryId = v ?? _categoryId),
            ),
            DropdownButtonFormField<String>(
              initialValue:
                  _propId == defaultPropId || propRegistry.containsKey(_propId)
                  ? _propId
                  : defaultPropId,
              decoration: const InputDecoration(labelText: Strings.fieldProp),
              items: [
                const DropdownMenuItem(
                  value: defaultPropId,
                  child: Text(Strings.usualItem),
                ),
                for (final e in propRegistry.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value.label)),
              ],
              onChanged: (v) => setState(() => _propId = v ?? defaultPropId),
            ),
          ),
          const SizedBox(height: 16),
          section(Strings.when, [
            DropdownButtonFormField<ScheduleType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: Strings.fieldRepeat),
              items: const [
                DropdownMenuItem(
                  value: ScheduleType.interval,
                  child: Text(Strings.repeatInterval),
                ),
                DropdownMenuItem(
                  value: ScheduleType.daily,
                  child: Text(Strings.repeatDaily),
                ),
                DropdownMenuItem(
                  value: ScheduleType.once,
                  child: Text(Strings.repeatOnce),
                ),
              ],
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            if (_type == ScheduleType.interval) ...[
              TextField(
                controller: _every,
                decoration: const InputDecoration(
                  labelText: Strings.fieldEvery,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              CheckboxListTile(
                value: !_allDay,
                onChanged: (v) => setState(() => _allDay = !(v ?? true)),
                title: const Text(Strings.onlyBetween),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              if (!_allDay)
                pair(
                  _TimeButton(
                    label: Strings.fieldFrom,
                    value: _activeFrom,
                    onTap: () => _pickTime(
                      _activeFrom,
                      (v) => setState(() => _activeFrom = v),
                    ),
                  ),
                  _TimeButton(
                    label: Strings.fieldUntil,
                    value: _activeTo,
                    onTap: () => _pickTime(
                      _activeTo,
                      (v) => setState(() => _activeTo = v),
                    ),
                  ),
                ),
            ],
            if (_type != ScheduleType.interval)
              pair(
                _TimeButton(
                  label: Strings.fieldTime,
                  value: _time,
                  onTap: () =>
                      _pickTime(_time, (v) => setState(() => _time = v)),
                ),
                _type == ScheduleType.once
                    ? _TimeButton(
                        label: Strings.fieldDate,
                        value: _date ?? Strings.pickDate,
                        raw: true,
                        onTap: _pickDate,
                      )
                    : const SizedBox.shrink(),
              ),
            if (_type == ScheduleType.daily)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.daysHint,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (var d = 0; d < 7; d++)
                        FilterChip(
                          label: Text(Strings.dayLetter[d]),
                          tooltip: Strings.dayShort[d],
                          selected: _days.contains(d),
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            fontFamily: bodyFont,
                            fontWeight: FontWeight.w700,
                            color: _days.contains(d) ? c.panel : c.ink,
                          ),
                          onSelected: (on) => setState(
                            () => on ? _days.add(d) : _days.remove(d),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            Text(
              describeSchedule(_build()),
              style: TextStyle(fontSize: 12.5, color: c.muted),
            ),
          ]),
          const SizedBox(height: 16),
          section(Strings.goalLegend, [
            pair(
              TextField(
                controller: _goal,
                decoration: const InputDecoration(
                  labelText: Strings.fieldGoal,
                  helperText: Strings.goalZeroHint,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
              ),
              TextField(
                controller: _unit,
                decoration: const InputDecoration(
                  labelText: Strings.fieldUnit,
                  hintText: Strings.unitHint,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _doneLabel,
            decoration: const InputDecoration(
              labelText: Strings.fieldDoneLabel,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(
                  widget.isNew ? Strings.addReminder : Strings.saveChanges,
                ),
              ),
              if (!widget.isNew || widget.initial.title.isNotEmpty)
                OutlinedButton(
                  onPressed: widget.onDone,
                  child: const Text(Strings.cancel),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.value,
    required this.onTap,
    this.raw = false,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  /// Show [value] as-is (dates) instead of as a 12-hour time.
  final bool raw;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(9),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(
          raw ? Icons.calendar_today_outlined : Icons.schedule,
          size: 18,
        ),
      ),
      child: Text(raw ? value : format12h(value)),
    ),
  );
}
