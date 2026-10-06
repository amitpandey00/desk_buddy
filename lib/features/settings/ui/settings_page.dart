import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:desk_buddy/app/providers.dart';
import 'package:desk_buddy/app/theme.dart';
import 'package:desk_buddy/core/clock/clock_provider.dart';
import 'package:desk_buddy/core/db/providers.dart';
import 'package:desk_buddy/features/analytics/domain/sample_history.dart';
import 'package:desk_buddy/features/categories/domain/category.dart';
import 'package:desk_buddy/features/settings/data/backup.dart';
import 'package:desk_buddy/features/settings/domain/app_settings.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:desk_buddy/shared/widgets/ui.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider).value;
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final reminders = ref.watch(remindersProvider).value ?? const [];
    if (s == null) return const SizedBox.shrink();
    final repo = ref.read(settingsRepositoryProvider);
    Future<void> update(AppSettings Function(AppSettings) f) => repo.update(f);

    // Each change is applied to the *current* row (not this build's
    // snapshot), so it can't undo an edit made a moment ago elsewhere.
    Widget toggle({
      required bool value,
      required ValueChanged<bool> onChanged,
    }) => Switch(
      value: value,
      activeTrackColor: context.desk.mint,
      onChanged: onChanged,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeader(
          Strings.navSettings,
          subtitle: Text(Strings.settingsSubtitle),
        ),
        TwoColumns(
          left: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Row(
                    Strings.setName,
                    Strings.setNameHint,
                    _NameField(
                      initial: s.userName,
                      onSave: (v) => update((x) => x.copyWith(userName: v)),
                    ),
                    first: true,
                  ),
                  _Row(
                    Strings.setShow,
                    Strings.setShowHint,
                    toggle(
                      value: s.buddyVisible,
                      onChanged: (v) =>
                          update((x) => x.copyWith(buddyVisible: v)),
                    ),
                  ),
                  _Row(
                    Strings.setAlways,
                    Strings.setAlwaysHint,
                    toggle(
                      value: s.buddyAlwaysOn,
                      onChanged: (v) =>
                          update((x) => x.copyWith(buddyAlwaysOn: v)),
                    ),
                  ),
                  _Row(
                    Strings.setWalk,
                    Strings.setWalkHint,
                    toggle(
                      value: s.walkEnabled,
                      onChanged: (v) =>
                          update((x) => x.copyWith(walkEnabled: v)),
                    ),
                  ),
                  _Row(
                    Strings.setSpeed,
                    Strings.speedValue(s.walkSpeed),
                    _SliderField(
                      value: s.walkSpeed,
                      min: AppSettings.speedMin,
                      max: AppSettings.speedMax,
                      label: Strings.setSpeed,
                      onSave: (v) => update((x) => x.copyWith(walkSpeed: v)),
                    ),
                  ),
                  _Row(
                    Strings.setSize,
                    Strings.sizeValue(s.buddySize),
                    _SliderField(
                      value: s.buddySize,
                      min: AppSettings.sizeMin,
                      max: AppSettings.sizeMax,
                      label: Strings.setSize,
                      onSave: (v) => update((x) => x.copyWith(buddySize: v)),
                    ),
                  ),
                  _Row(
                    Strings.setSound,
                    Strings.setSoundHint,
                    toggle(
                      value: s.soundEnabled,
                      onChanged: (v) =>
                          update((x) => x.copyWith(soundEnabled: v)),
                    ),
                  ),
                  _Row(
                    Strings.setSnooze,
                    Strings.setSnoozeHint,
                    _MinutesDropdown(
                      value: s.snoozeMinutes,
                      options: AppSettings.snoozeOptions,
                      onChanged: (v) =>
                          update((x) => x.copyWith(snoozeMinutes: v)),
                    ),
                  ),
                  _Row(
                    Strings.setAutoMiss,
                    Strings.setAutoMissHint,
                    _MinutesDropdown(
                      value: s.autoMissMinutes,
                      options: AppSettings.autoMissOptions,
                      onChanged: (v) =>
                          update((x) => x.copyWith(autoMissMinutes: v)),
                    ),
                  ),
                  _Row(
                    Strings.doNotDisturb,
                    Strings.setDndHint,
                    toggle(
                      value: s.doNotDisturb,
                      onChanged: (v) =>
                          update((x) => x.copyWith(doNotDisturb: v)),
                    ),
                  ),
                  _Row(
                    Strings.setLogin,
                    Strings.setLoginHint,
                    toggle(
                      value: s.launchAtLogin,
                      onChanged: (v) =>
                          update((x) => x.copyWith(launchAtLogin: v)),
                    ),
                  ),
                  _Row(
                    Strings.setFocus,
                    Strings.setFocusHint,
                    toggle(
                      value: s.focusPopups,
                      onChanged: (v) =>
                          update((x) => x.copyWith(focusPopups: v)),
                    ),
                  ),
                  _Row(
                    Strings.setTheme,
                    null,
                    DropdownButton<ThemePreference>(
                      value: s.themeMode,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: [
                        for (final t in ThemePreference.values)
                          DropdownMenuItem(
                            value: t,
                            child: Text(Strings.themeName(t.name)),
                          ),
                      ],
                      onChanged: (t) => update(
                        (x) => x.copyWith(themeMode: t ?? x.themeMode),
                      ),
                    ),
                  ),
                  _Row(
                    Strings.setBackup,
                    Strings.setBackupHint,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => _export(context, ref),
                          child: const Text(Strings.exportData),
                        ),
                        OutlinedButton(
                          onPressed: () => _import(context, ref),
                          child: const Text(Strings.importData),
                        ),
                      ],
                    ),
                    wideControl: false,
                    below: true,
                  ),
                  _Row(
                    Strings.setReset,
                    Strings.setResetHint,
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.desk.coral,
                      ),
                      onPressed: () => _confirmReset(context, ref),
                      child: const Text(Strings.resetEverything),
                    ),
                    wideControl: false,
                  ),
                  if (kDebugMode)
                    _Row(
                      Strings.devTitle,
                      Strings.devHint,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              final data = ref.read(appDataProvider);
                              await data.log.addAll(
                                generateSampleHistory(
                                  reminders: reminders,
                                  now: ref
                                      .read(appClockProvider)
                                      .now()
                                      .millisecondsSinceEpoch,
                                  wallClock: ref.read(wallClockProvider),
                                  newId: data.log.newId,
                                ),
                              );
                              if (context.mounted) {
                                showToast(context, Strings.sampleAdded);
                              }
                            },
                            child: const Text(Strings.generateSample),
                          ),
                          OutlinedButton(
                            onPressed: () =>
                                ref.read(logRepositoryProvider).deleteSamples(),
                            child: const Text(Strings.removeSample),
                          ),
                        ],
                      ),
                      wideControl: false,
                      below: true,
                    ),
                ],
              ),
            ),
          ),
          right: Panel(
            title: Strings.categoriesTitle,
            child: _CategoriesEditor(
              categories: categories,
              usage: {
                for (final c in categories)
                  c.id: reminders.where((r) => r.categoryId == c.id).length,
              },
            ),
          ),
        ),
      ],
    );
  }

  static const _jsonFiles = XTypeGroup(
    label: Strings.backupFileType,
    extensions: ['json'],
  );

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final now = ref.read(appClockProvider).now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final target = await getSaveLocation(
      suggestedName: Strings.backupFileName(date),
      acceptedTypeGroups: const [_jsonFiles],
    );
    if (target == null) return;
    final json = await BackupService(ref.read(appDataProvider)).export();
    await File(target.path).writeAsString(
      const JsonEncoder.withIndent('  ').convert(json),
      flush: true,
    );
    if (context.mounted) showToast(context, Strings.exported);
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final file = await openFile(acceptedTypeGroups: const [_jsonFiles]);
    if (file == null) return;
    final Backup backup;
    try {
      backup = BackupService.parse(jsonDecode(await file.readAsString()));
    } on BackupException catch (e) {
      if (context.mounted) showToast(context, e.message);
      return;
    } on FormatException {
      if (context.mounted) showToast(context, Strings.backupDamaged);
      return;
    }
    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Strings.importConfirmTitle),
        content: Text(
          Strings.importConfirmBody(
            backup.reminders.length,
            backup.log.length,
            backup.exportedAt?.split('T').first,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(Strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(Strings.importAction),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await BackupService(ref.read(appDataProvider)).restore(backup);
    } on Object {
      // Rolled back: nothing changed.
      if (context.mounted) showToast(context, Strings.backupRestoreFailed);
      return;
    }
    if (context.mounted) showToast(context, Strings.imported);
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(Strings.resetConfirmTitle),
        content: const Text(Strings.resetConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(Strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.desk.coral,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(Strings.resetEverything),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(appDataProvider).resetEverything(ref.read(seedDataProvider));
    if (context.mounted) showToast(context, Strings.resetDone);
  }
}

class _Row extends StatelessWidget {
  const _Row(
    this.title,
    this.hint,
    this.control, {
    this.first = false,
    this.wideControl = true,
    this.below = false,
  });

  final String title;
  final String? hint;
  final Widget control;
  final bool first;

  /// Give the control a fixed width (sliders, fields) vs. its own size.
  final bool wideControl;

  /// Put the control under the text (rows with several buttons).
  final bool below;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: first ? null : Border(top: BorderSide(color: context.desk.line)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: () {
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            if (hint != null)
              Text(
                hint!,
                style: TextStyle(fontSize: 13, color: context.desk.muted),
              ),
          ],
        );
        final labelled = Semantics(
          label: title,
          child: wideControl && control is! Switch
              ? SizedBox(width: 200, child: control)
              : control,
        );
        return below
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [text, const SizedBox(height: 10), labelled],
              )
            : Row(
                children: [
                  Expanded(child: text),
                  const SizedBox(width: 16),
                  labelled,
                ],
              );
      }(),
    ),
  );
}

/// Saves on Enter or when focus leaves.
class _NameField extends StatefulWidget {
  const _NameField({required this.initial, required this.onSave});
  final String initial;
  final ValueChanged<String> onSave;

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final _c = TextEditingController(text: _shown(widget.initial));
  final _focus = FocusNode();

  static String _shown(String name) =>
      name == Strings.defaultUserName ? '' : name;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _save();
    });
  }

  @override
  void didUpdateWidget(_NameField old) {
    super.didUpdateWidget(old);
    // Changed elsewhere (import, reset, the other window): show it, unless
    // the user is typing here.
    if (!_focus.hasFocus && old.initial != widget.initial) {
      _c.text = _shown(widget.initial);
    }
  }

  /// Saves only real edits, so leaving the field never writes an old name
  /// back over a newer one.
  void _save() {
    final v = _c.text.trim();
    if (v != _shown(widget.initial)) widget.onSave(v);
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _c,
    focusNode: _focus,
    decoration: const InputDecoration(hintText: Strings.namePlaceholder),
    inputFormatters: [LengthLimitingTextInputFormatter(40)],
    onSubmitted: (_) => _save(),
  );
}

/// Updates its label live while dragging; saves when released.
class _SliderField extends StatefulWidget {
  const _SliderField({
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onSave,
  });

  final int value;
  final int min;
  final int max;
  final String label;
  final ValueChanged<int> onSave;

  @override
  State<_SliderField> createState() => _SliderFieldState();
}

class _SliderFieldState extends State<_SliderField> {
  double? _dragging;

  @override
  Widget build(BuildContext context) => Slider(
    value: (_dragging ?? widget.value.toDouble()).clamp(
      widget.min.toDouble(),
      widget.max.toDouble(),
    ),
    min: widget.min.toDouble(),
    max: widget.max.toDouble(),
    label: '${(_dragging ?? widget.value).round()}',
    semanticFormatterCallback: (v) => '${widget.label} ${v.round()}',
    onChanged: (v) => setState(() => _dragging = v),
    onChangeEnd: (v) {
      widget.onSave(v.round());
      setState(() => _dragging = null);
    },
  );
}

class _MinutesDropdown extends StatelessWidget {
  const _MinutesDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButton<int>(
    value: options.contains(value) ? value : options.first,
    isExpanded: true,
    underline: const SizedBox.shrink(),
    items: [
      for (final m in options)
        DropdownMenuItem(value: m, child: Text(Strings.minutesOption(m))),
    ],
    onChanged: (v) {
      if (v != null) onChanged(v);
    },
  );
}

class _CategoriesEditor extends ConsumerWidget {
  const _CategoriesEditor({required this.categories, required this.usage});

  final List<Category> categories;
  final Map<String, int> usage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(categoryRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.categoriesHint,
          style: TextStyle(fontSize: 13, color: context.desk.muted),
        ),
        const SizedBox(height: 12),
        for (final (i, c) in categories.indexed)
          DecoratedBox(
            key: ValueKey(c.id),
            decoration: BoxDecoration(
              border: i == 0
                  ? null
                  : Border(top: BorderSide(color: context.desk.line)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: _CommitField(
                      initial: c.emoji,
                      label: Strings.categoryIcon,
                      maxLength: 4,
                      center: true,
                      onCommit: (v) =>
                          repo.updateWith(c.id, (x) => x.copyWith(emoji: v)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CommitField(
                      initial: c.name,
                      label: Strings.categoryName,
                      onCommit: (v) =>
                          repo.updateWith(c.id, (x) => x.copyWith(name: v)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ColorField(
                    hex: c.colorHex,
                    label: Strings.categoryColor(c.name),
                    onChanged: (h) =>
                        repo.updateWith(c.id, (x) => x.copyWith(colorHex: h)),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: (usage[c.id] ?? 0) > 0
                        ? Strings.deleteMoves(usage[c.id]!)
                        : '',
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: context.desk.coral,
                      ),
                      onPressed: categories.length < 2
                          ? null
                          : () async {
                              await repo.delete(c.id);
                              if (context.mounted) {
                                showToast(context, Strings.categoryDeleted);
                              }
                            },
                      child: const Text(Strings.delete),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: () => unawaited(repo.create()),
            child: const Text(Strings.addCategory),
          ),
        ),
      ],
    );
  }
}

/// A text field that saves non-empty input on Enter / focus loss, and
/// reverts to the stored value if left empty.
class _CommitField extends StatefulWidget {
  const _CommitField({
    required this.initial,
    required this.label,
    required this.onCommit,
    this.maxLength,
    this.center = false,
  });

  final String initial;
  final String label;
  final ValueChanged<String> onCommit;
  final int? maxLength;
  final bool center;

  @override
  State<_CommitField> createState() => _CommitFieldState();
}

class _CommitFieldState extends State<_CommitField> {
  late final _c = TextEditingController(text: widget.initial);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(_CommitField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && old.initial != widget.initial) {
      _c.text = widget.initial;
    }
  }

  void _commit() {
    final v = _c.text.trim();
    if (v.isEmpty) {
      _c.text = widget.initial;
    } else if (v != widget.initial) {
      widget.onCommit(v);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _c,
    focusNode: _focus,
    textAlign: widget.center ? TextAlign.center : TextAlign.start,
    decoration: InputDecoration(hintText: widget.label),
    inputFormatters: [
      if (widget.maxLength != null)
        LengthLimitingTextInputFormatter(widget.maxLength),
    ],
    onSubmitted: (_) => _commit(),
  );
}
