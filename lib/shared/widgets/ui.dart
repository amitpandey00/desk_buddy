import 'package:desk_buddy/app/providers.dart';
import 'package:desk_buddy/app/theme.dart';
import 'package:desk_buddy/features/reminders/domain/log_entry.dart';
import 'package:desk_buddy/shared/color_hex.dart';
import 'package:desk_buddy/shared/format/countdown.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The prototype's `.box`: a bordered panel.
class Panel extends StatelessWidget {
  const Panel({required this.child, this.title, this.trailing, super.key});

  final Widget child;
  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                // May shrink (e.g. a dropdown with long reminder titles).
                if (trailing != null) Flexible(child: trailing!),
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    ),
  );
}

/// Rounded emoji square tinted with a category color.
class EmojiTile extends StatelessWidget {
  const EmojiTile(this.emoji, {required this.colorHex, super.key});

  final String emoji;
  final String colorHex;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorFromHex(colorHex).withValues(alpha: .13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    ),
  );
}

/// done / snoozed / missed / logged pill.
class StatusTag extends StatelessWidget {
  const StatusTag(this.entry, {super.key});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final (label, fg, bg) = entry.manual
        ? (Strings.tagLogged, c.mint, c.mint.withValues(alpha: .18))
        : switch (entry.action) {
            LogAction.done => (
              Strings.tagDone,
              c.mint,
              c.mint.withValues(alpha: .18),
            ),
            LogAction.snoozed => (
              Strings.tagSnoozed,
              const Color(0xFF9A6B00),
              c.sun.withValues(alpha: .3),
            ),
            LogAction.skipped => (
              Strings.tagSkipped,
              c.muted,
              c.muted.withValues(alpha: .16),
            ),
            LogAction.missed => (
              Strings.tagMissed,
              c.coral,
              c.coral.withValues(alpha: .16),
            ),
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// "in 12 min", updated every second.
class LiveCountdown extends ConsumerWidget {
  const LiveCountdown(this.dueAt, {this.style, super.key});

  final int dueAt;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider).value ?? dueAt;
    return Text(formatCountdown(dueAt - now), style: style);
  }
}

void showToast(BuildContext context, String message, {SnackBarAction? action}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: action,
        duration: const Duration(milliseconds: 2400),
        width: 420,
      ),
    );
}

/// A color swatch that opens a small picker (palette + hex field).
class ColorField extends StatelessWidget {
  const ColorField({
    required this.hex,
    required this.onChanged,
    required this.label,
    super.key,
  });

  final String hex;
  final ValueChanged<String> onChanged;

  /// For screen readers ("Jacket color").
  final String label;

  static const palette = [
    '#1C2733', '#5E6D7C', '#F4F4F4', '#FFFFFF', //
    '#E8473A', '#F0A020', '#FFCB2E', '#1FA97F',
    '#2F7DE1', '#4E7FB8', '#2F3E50', '#8B5CF6',
    '#E9B48A', '#F1C9A5', '#C68A5E', '#8D5B3E',
    '#2B1B12', '#5A3A22', '#111111', '#3A3F47',
    '#DCE8F2', '#F3E7C9', '#64748B', '#EC4899',
  ];

  Future<void> _pick(BuildContext context) async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => _ColorDialog(initial: hex, title: label),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$label, ${hex.toUpperCase()}',
    child: InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(color: context.desk.line),
          borderRadius: BorderRadius.circular(8),
          color: context.desk.panel2,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorFromHex(hex),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    ),
  );
}

class _ColorDialog extends StatefulWidget {
  const _ColorDialog({required this.initial, required this.title});
  final String initial;
  final String title;

  @override
  State<_ColorDialog> createState() => _ColorDialogState();
}

class _ColorDialogState extends State<_ColorDialog> {
  late final _hex = TextEditingController(text: widget.initial.toUpperCase());

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  bool get _valid => RegExp(r'^#?[0-9a-fA-F]{6}$').hasMatch(_hex.text.trim());

  String get _normalized {
    final t = _hex.text.trim().toUpperCase();
    return t.startsWith('#') ? t : '#$t';
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in ColorField.palette)
                Semantics(
                  button: true,
                  label: c,
                  child: InkWell(
                    onTap: () => Navigator.pop(context, c),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: colorFromHex(c),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: context.desk.line),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hex,
            decoration: const InputDecoration(labelText: Strings.hexColor),
            inputFormatters: [LengthLimitingTextInputFormatter(7)],
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (_valid) Navigator.pop(context, _normalized);
            },
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(Strings.cancel),
      ),
      FilledButton(
        onPressed: _valid ? () => Navigator.pop(context, _normalized) : null,
        child: const Text(Strings.useColor),
      ),
    ],
  );
}

/// Lays children side by side when wide, stacked when narrow (the
/// prototype's `.g2` grid with its 860 px breakpoint).
class TwoColumns extends StatelessWidget {
  const TwoColumns({
    required this.left,
    required this.right,
    this.leftFlex = 11,
    this.rightFlex = 10,
    super.key,
  });

  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => c.maxWidth < 760
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 18), right],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: leftFlex, child: left),
              const SizedBox(width: 18),
              Expanded(flex: rightFlex, child: right),
            ],
          ),
  );
}

/// Page title + subtitle used at the top of every section.
class PageHeader extends StatelessWidget {
  const PageHeader(this.title, {this.subtitle, super.key});

  final String title;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.displaySmall),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          DefaultTextStyle.merge(
            style: TextStyle(color: context.desk.muted, fontSize: 15),
            child: subtitle!,
          ),
        ],
      ],
    ),
  );
}
