import 'package:flutter/widgets.dart';

const _sun = Color(0xFFFFCB2E);
const _coral = Color(0xFFE8473A);
const _ink = Color(0xFF1C2733);
const _white = Color(0xFFFFFFFF);
const _accent = Color(0xFF2F7DE1);

class BubbleAction {
  const BubbleAction(this.label, this.onPressed, {this.primary = false});
  final String label;
  final VoidCallback onPressed;

  /// The dark "done" button; others are white.
  final bool primary;
}

/// The comic-style speech bubble: yellow text with a thick coral outline,
/// an optional goal pill and action buttons. Never mirrored.
class BuddyBubble extends StatelessWidget {
  const BuddyBubble({
    required this.message,
    this.emoji = '',
    this.progress,
    this.actions = const [],
    this.compact = false,
    this.maxWidth = 310,
    this.autofocus = true,
    super.key,
  });

  /// The already-filled message text.
  final String message;
  final String emoji;

  /// e.g. "3 / 10 pages today" — shown as a white pill when set.
  final String? progress;
  final List<BubbleAction> actions;

  /// Smaller text and no buttons: the tap-to-peek bubble.
  final bool compact;
  final double maxWidth;

  /// Focus the primary action when shown (keyboard users answer with Enter).
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      ComicText(message, emoji: emoji, fontSize: compact ? 21 : 25),
      if (progress != null) ...[
        const SizedBox(height: 10),
        _Pill(progress!),
      ],
      if (actions.isNotEmpty) ...[
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in actions)
              // The primary action takes focus so Enter answers the bubble.
              _BubbleButton(a, autofocus: autofocus && a.primary),
          ],
        ),
      ],
    ];
    return Semantics(
      container: true,
      liveRegion: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: FocusTraversalGroup(
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

/// Yellow fill over a 5 px coral stroke (the stroke sits behind the fill, as
/// CSS `paint-order: stroke fill` does), with a soft drop shadow. Emoji are
/// excluded from the stroke.
class ComicText extends StatelessWidget {
  const ComicText(this.text, {this.emoji = '', this.fontSize = 25, super.key});

  final String text;
  final String emoji;
  final double fontSize;

  TextSpan _span({required bool stroke}) {
    final base = TextStyle(
      fontFamily: 'Baloo2',
      fontWeight: FontWeight.w800,
      fontSize: fontSize,
      height: 1.08,
      foreground: stroke
          ? (Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 5
              ..strokeJoin = StrokeJoin.round
              ..color = _coral)
          : null,
      color: stroke ? null : _sun,
      shadows: stroke
          ? const [Shadow(offset: Offset(0, 3), color: Color(0x40000000))]
          : null,
    );
    return TextSpan(
      style: base,
      children: [
        if (emoji.isNotEmpty)
          TextSpan(
            text: '$emoji ',
            style: TextStyle(
              fontSize: fontSize * 1.2,
              // Same layout, but no outline around the emoji.
              foreground: stroke
                  ? (Paint()..color = const Color(0x00000000))
                  : null,
              shadows: const [],
            ),
          ),
        TextSpan(text: text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: emoji.isEmpty ? text : '$emoji $text',
    child: ExcludeSemantics(
      child: Stack(
        children: [
          Text.rich(_span(stroke: true), textAlign: TextAlign.center),
          Text.rich(_span(stroke: false), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: _white,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Figtree',
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: _ink,
        ),
      ),
    ),
  );
}

/// Focusable, Enter/Space-activatable button (no Material in the overlay).
class _BubbleButton extends StatefulWidget {
  const _BubbleButton(this.action, {this.autofocus = false});
  final BubbleAction action;
  final bool autofocus;

  @override
  State<_BubbleButton> createState() => _BubbleButtonState();
}

class _BubbleButtonState extends State<_BubbleButton> {
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    final bg = a.primary ? _ink : _white;
    final fg = a.primary ? _white : _ink;
    return Semantics(
      button: true,
      label: a.label,
      child: FocusableActionDetector(
        autofocus: widget.autofocus,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => a.onPressed(),
          ),
        },
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        child: GestureDetector(
          onTap: a.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: _hovered ? Color.lerp(bg, _accent, .12) : bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _focused ? _accent : const Color(0x00000000),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), offset: Offset(0, 2)),
                BoxShadow(
                  color: Color(0x2E000000),
                  offset: Offset(0, 6),
                  blurRadius: 16,
                ),
              ],
            ),
            child: ExcludeSemantics(
              child: Text(
                a.label,
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Springy scale-in (0.6 → 1, prototype's `cubic-bezier(.2,1.6,.4,1)`).
/// Give it a new key to replay. Skipped when [animate] is false.
class PopIn extends StatefulWidget {
  const PopIn({required this.child, this.animate = true, super.key});
  final Widget child;
  final bool animate;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    value: widget.animate ? 0 : 1,
  )..forward();
  late final Animation<double> _scale = Tween<double>(
    begin: .6,
    end: 1,
  ).animate(CurvedAnimation(parent: _c, curve: const Cubic(.2, 1.6, .4, 1)));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
    child: ScaleTransition(
      scale: _scale,
      alignment: Alignment.bottomCenter,
      child: widget.child,
    ),
  );
}
