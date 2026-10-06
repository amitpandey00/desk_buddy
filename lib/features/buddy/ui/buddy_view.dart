import 'dart:async';

import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/buddy/movement/buddy_pose.dart';
import 'package:desk_buddy/features/buddy/render/buddy_painter.dart';
import 'package:desk_buddy/features/buddy/render/props.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// The animated character.
///
/// Frame budget: walking and alert animate every vsync; idle and dragging
/// only breathe and blink, so they repaint at [idleFps]; with reduce motion
/// nothing loops and it repaints only when its inputs change. The pose
/// updates go through a listenable, so frames never rebuild widgets.
class BuddyView extends StatefulWidget {
  const BuddyView({
    required this.look,
    required this.state,
    this.propId,
    this.flip = false,
    this.width = 120,
    this.reduceMotion,
    this.idleFps = 15,
    super.key,
  });

  final BuddyLook look;
  final BuddyState state;

  /// Prop to hold right now (e.g. the firing reminder's). `null` or
  /// `default` means the look's usual item.
  final String? propId;

  /// Mirror for walking left. Only the character flips — never the bubble.
  final bool flip;

  /// Logical width; height follows the 120×222 design ratio.
  final double width;

  /// Overrides the platform reduce-motion setting (tests, settings).
  final bool? reduceMotion;

  final int idleFps;

  double get height => width * buddyDesignSize.height / buddyDesignSize.width;

  @override
  State<BuddyView> createState() => _BuddyViewState();
}

class _BuddyViewState extends State<BuddyView>
    with SingleTickerProviderStateMixin {
  // Monotonic animation time — not wall-clock time, so `clock` isn't needed.
  final _time = Stopwatch()..start();
  final _pose = ValueNotifier<BuddyPose>(BuddyPose.rest);
  late final Ticker _ticker = createTicker((_) => _update());
  Timer? _slowTimer;
  late BuddyPalette _palette = BuddyPalette.of(widget.look);
  late PropDef _prop = _resolveProp();

  bool get _reduceMotion =>
      widget.reduceMotion ??
      MediaQuery.maybeDisableAnimationsOf(context) ??
      false;

  PropDef _resolveProp() =>
      resolveProp(widget.propId, widget.look.defaultPropId);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schedule();
  }

  @override
  void didUpdateWidget(BuddyView old) {
    super.didUpdateWidget(old);
    if (old.look != widget.look) _palette = BuddyPalette.of(widget.look);
    if (old.look != widget.look || old.propId != widget.propId) {
      _prop = _resolveProp();
    }
    if (old.state != widget.state ||
        old.reduceMotion != widget.reduceMotion ||
        old.idleFps != widget.idleFps) {
      _schedule();
    }
  }

  void _schedule() {
    _ticker.stop();
    _slowTimer?.cancel();
    _update();
    if (_reduceMotion) return;
    switch (widget.state) {
      case BuddyState.walking || BuddyState.alert:
        unawaited(_ticker.start());
      case BuddyState.idle || BuddyState.dragging || BuddyState.sad:
        _slowTimer = Timer.periodic(
          Duration(microseconds: 1000000 ~/ widget.idleFps),
          (_) => _update(),
        );
    }
  }

  void _update() {
    _pose.value = poseAt(
      widget.state,
      _time.elapsedMicroseconds / 1e6,
      reduceMotion: _reduceMotion,
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _slowTimer?.cancel();
    _pose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: Strings.buddyLabel,
    hint: Strings.buddyHint,
    button: true,
    child: RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        painter: BuddyPainter(
          palette: _palette,
          look: widget.look,
          prop: _prop,
          pose: _pose,
          flip: widget.flip,
        ),
      ),
    ),
  );
}
