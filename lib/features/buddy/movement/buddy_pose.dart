import 'dart:math';

/// What the buddy is doing. Drives both movement and limb animation.
enum BuddyState { walking, idle, alert, dragging }

/// Joint angles (radians, clockwise-positive like the canvas) and offsets
/// (design px, in the 120×222 space) for one frame.
class BuddyPose {
  const BuddyPose({
    this.legFront = 0,
    this.legBack = 0,
    this.armBack = 0,
    this.bodyDy = 0,
    this.eyeScaleY = 1,
  });

  /// The left (`leg l`) and right (`leg r`) legs of the prototype.
  final double legFront;
  final double legBack;

  /// The arm drawn behind the torso; swings when walking, waves on alert.
  final double armBack;

  /// Vertical offset of everything but the floor shadow (negative = up).
  final double bodyDy;

  /// 1 = open, 0.1 = mid-blink.
  final double eyeScaleY;

  static const rest = BuddyPose();

  @override
  String toString() =>
      'BuddyPose(legs ${_fmt(legFront)}/${_fmt(legBack)}°, '
      'arm ${_fmt(armBack)}°, dy ${bodyDy.toStringAsFixed(2)}, '
      'eyes ${eyeScaleY.toStringAsFixed(2)})';

  static String _fmt(double r) => (r / _deg).toStringAsFixed(1);
}

const double _deg = pi / 180;

/// CSS-like `ease-in-out` between 0 and 1.
double _easeInOut(double x) => (1 - cos(pi * x)) / 2;

/// An `alternate` keyframe loop: [from] → [to] over [half] seconds, then back.
double _alternate(double t, double half, double from, double to) {
  var x = (t % (2 * half)) / half;
  if (x > 1) x = 2 - x;
  return from + (to - from) * _easeInOut(x);
}

/// Eyes: open until 94% of a 4.5 s cycle, shut at 96%, open again at 100%.
double _blink(double t) {
  final p = (t % 4.5) / 4.5;
  if (p < .94) return 1;
  if (p < .96) return 1 - .9 * _easeInOut((p - .94) / .02);
  return .1 + .9 * _easeInOut((p - .96) / .04);
}

/// The pose for [state] at [t] seconds into the animation.
///
/// Matches the prototype's CSS keyframes: walking swings legs ±16° on a 1 s
/// cycle with a 3 px bob; idle breathes 1.5 px over 2.4 s; alert hops 9 px
/// every 0.9 s while the back arm waves between -165° and -125°. Dragging
/// uses the idle pose. With [reduceMotion] nothing loops: limbs rest, and an
/// alert keeps the arm raised so it still reads as "hey!".
BuddyPose poseAt(BuddyState state, double t, {bool reduceMotion = false}) {
  if (reduceMotion) {
    return state == BuddyState.alert
        ? const BuddyPose(armBack: -145 * _deg)
        : BuddyPose.rest;
  }
  final eyes = _blink(t);
  switch (state) {
    case BuddyState.walking:
      final swing = _alternate(t, .5, -16 * _deg, 16 * _deg);
      return BuddyPose(
        legFront: swing,
        legBack: -swing,
        armBack: swing,
        bodyDy: _alternate(t, .25, 0, -3),
        eyeScaleY: eyes,
      );
    case BuddyState.idle || BuddyState.dragging:
      return BuddyPose(
        // 0 → -1.5 px at 50% → 0.
        bodyDy: -1.5 * (1 - cos(2 * pi * t / 2.4)) / 2,
        eyeScaleY: eyes,
      );
    case BuddyState.alert:
      final p = (t % .9) / .9;
      final hop = p < .3
          ? -9 * _easeInOut(p / .3)
          : p < .6
          ? -9 * (1 - _easeInOut((p - .3) / .3))
          : 0.0;
      return BuddyPose(
        armBack: _alternate(t, .45, -165 * _deg, -125 * _deg),
        bodyDy: hop,
        eyeScaleY: eyes,
      );
  }
}
