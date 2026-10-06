import 'package:desk_buddy/app/providers.dart';
import 'package:desk_buddy/app/theme.dart';
import 'package:desk_buddy/core/db/providers.dart';
import 'package:desk_buddy/features/categories/domain/category.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/features/reminders/ui/reminder_editor.dart';
import 'package:desk_buddy/shared/format/schedule_describe.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:desk_buddy/shared/widgets/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemindersPage extends ConsumerStatefulWidget {
  const RemindersPage({super.key});

  @override
  ConsumerState<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends ConsumerState<RemindersPage> {
  /// What the editor shows; null = a fresh blank reminder.
  Reminder? _editing;
  bool _isNew = true;
  int _blankSerial = 0;

  /// The fresh reminder behind "New reminder". Made once per blank form:
  /// a new id on every build would re-key the editor and wipe what the user
  /// is typing whenever any data refreshes.
  Reminder? _blank;

  void _edit(Reminder r) => setState(() {
    _editing = r;
    _isNew = false;
  });

  void _closeEditor() => setState(() {
    _editing = null;
    _isNew = true;
    _blank = null;
    _blankSerial++;
  });

  Future<void> _loadStarter(int index) async {
    final starter = ref.read(seedDataProvider).starters[index];
    // Resolves (or creates) the starter's category; nothing else is saved.
    final r = await ref
        .read(appDataProvider)
        .seeder
        .reminderFromStarter(
          starter,
        );
    if (!mounted) return;
    setState(() {
      _editing = r;
      _isNew = true;
    });
    showToast(context, Strings.starterLoaded);
  }

  Future<void> _delete(Reminder r) async {
    // Read now: Undo may be pressed after this page is gone.
    final repo = ref.read(reminderRepositoryProvider);
    await ref.read(reminderCommandsProvider).delete(r.id);
    if (!mounted) return;
    if (_editing?.id == r.id) _closeEditor();
    showToast(
      context,
      Strings.reminderDeleted,
      action: SnackBarAction(
        label: Strings.undo,
        // Restored unscheduled: the scheduler plans it from now (D11)
        // rather than reviving a due time that may have passed.
        onPressed: () => repo.save(r.copyWith(nextDueAt: null)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersProvider).value ?? const [];
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final starters = ref.watch(seedDataProvider).starters;
    final commands = ref.watch(reminderCommandsProvider);
    if (_editing == null && _blank == null && categories.isNotEmpty) {
      _blank = commands.blank(categoryId: categories.first.id);
    }
    final editing = _editing ?? _blank;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeader(
          Strings.navReminders,
          subtitle: Text(Strings.remindersSubtitle),
        ),
        TwoColumns(
          left: Panel(
            title: Strings.yourReminders,
            child: reminders.isEmpty
                ? Text(
                    Strings.noRemindersYet,
                    style: TextStyle(color: context.desk.muted),
                  )
                : Column(
                    children: [
                      for (final (i, r) in reminders.indexed)
                        _ReminderCard(
                          reminder: r,
                          category: categoryFor(categories, r.categoryId),
                          first: i == 0,
                          onEdit: () => _edit(r),
                          onDelete: () => _delete(r),
                        ),
                    ],
                  ),
          ),
          right: Panel(
            title: _isNew ? Strings.newReminder : Strings.editReminder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isNew && _editing == null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (i, s) in starters.indexed)
                        ActionChip(
                          label: Text('${s.emoji} ${s.title}'),
                          onPressed: () => _loadStarter(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                if (editing != null)
                  ReminderEditor(
                    key: ValueKey('${editing.id}-$_blankSerial'),
                    initial: editing,
                    isNew: _isNew,
                    categories: categories,
                    onDone: _closeEditor,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({
    required this.reminder,
    required this.category,
    required this.first,
    required this.onEdit,
    required this.onDelete,
  });

  final Reminder reminder;
  final Category category;
  final bool first;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.desk;
    final r = reminder;
    final meta = [
      category.name,
      describeSchedule(r),
      if (r.dailyGoal > 0) Strings.goalShort(r.dailyGoal, r.goalUnit),
    ].join(' · ');
    final details = Row(
      children: [
        EmojiTile(r.emoji, colorHex: category.colorHex),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Wrap(
                children: [
                  Text(meta, style: TextStyle(fontSize: 13, color: c.muted)),
                  if (r.enabled && r.nextDueAt != null) ...[
                    Text(
                      ' · ${Strings.nextIn}',
                      style: TextStyle(fontSize: 13, color: c.muted),
                    ),
                    LiveCountdown(
                      r.nextDueAt!,
                      style: TextStyle(fontSize: 13, color: c.muted),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
    final actions = Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Semantics(
          label: Strings.toggleReminder(r.title),
          child: Switch(
            value: r.enabled,
            activeTrackColor: c.mint,
            onChanged: (v) =>
                ref.read(reminderCommandsProvider).setEnabled(r.id, enabled: v),
          ),
        ),
        _SmallButton(
          Strings.test,
          onPressed: () => ref.read(windowBusProvider).testReminder(r.id),
        ),
        _SmallButton(Strings.edit, onPressed: onEdit),
        _SmallButton(Strings.delete, onPressed: onDelete, danger: true),
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: c.line)),
      ),
      child: Opacity(
        opacity: r.enabled ? 1 : .55,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: LayoutBuilder(
            builder: (context, box) => box.maxWidth < 520
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [details, const SizedBox(height: 8), actions],
                  )
                : Row(
                    children: [
                      Expanded(child: details),
                      actions,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton(
    this.label, {
    required this.onPressed,
    this.danger = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      minimumSize: const Size(0, 32),
      foregroundColor: danger ? context.desk.coral : null,
      textStyle: const TextStyle(
        fontFamily: bodyFont,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
    child: Text(label),
  );
}
