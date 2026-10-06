import 'dart:math';

enum WalkMode { walking, idle }

/// Decides where the buddy walks. Pure Dart: time only advances through
/// [step], and randomness is injectable, so behavior is fully testable.
///
/// Mirrors the prototype: walk for 4–11 s, idle for 1.5–5 s, and after an
/// idle there is a 40% chance of turning around. Bounces off the edges.
class Walker {
  Walker({Random? random, this.alwaysWalk = false, double initialX = 0})
    : _random = random ?? Random(),
      x = initialX;

  final Random _random;

  /// Never idles (used for benchmarks).
  final bool alwaysWalk;

  /// Left edge of the buddy, in whatever unit the caller uses.
  double x;

  /// 1 = moving right, -1 = moving left.
  int dir = 1;

  WalkMode mode = WalkMode.walking;

  /// Seconds left in the current [mode].
  double remaining = 6;

  /// Advances the walker by [dt] seconds within `[minX, maxX]`.
  void step(
    double dt, {
    required double minX,
    required double maxX,
    required double speed,
  }) {
    if (!alwaysWalk) {
      remaining -= dt;
      if (remaining <= 0) {
        if (mode == WalkMode.walking) {
          mode = WalkMode.idle;
          remaining = 1.5 + _random.nextDouble() * 3.5;
        } else {
          mode = WalkMode.walking;
          if (_random.nextDouble() < .4) dir = -dir;
          remaining = 4 + _random.nextDouble() * 7;
        }
      }
    }
    if (mode == WalkMode.walking) {
      x += dir * speed * dt;
    }
    if (maxX <= minX) {
      x = minX;
      return;
    }
    if (x <= minX) {
      x = minX;
      dir = 1;
    } else if (x >= maxX) {
      x = maxX;
      dir = -1;
    }
  }
}
