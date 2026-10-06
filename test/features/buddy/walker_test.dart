import 'dart:math';

import 'package:desk_buddy/features/buddy/movement/walker.dart';
import 'package:flutter_test/flutter_test.dart';

/// Returns a fixed sequence so mode lengths and turn decisions are known.
class _SeqRandom implements Random {
  _SeqRandom(this.values);
  final List<double> values;
  int _i = 0;

  @override
  double nextDouble() => values[_i++ % values.length];

  @override
  bool nextBool() => nextDouble() < .5;

  @override
  int nextInt(int max) => (nextDouble() * max).floor();
}

void main() {
  void run(Walker w, double seconds, {double maxX = 1000}) {
    for (var t = 0.0; t < seconds; t += .01) {
      w.step(.01, minX: 0, maxX: maxX, speed: 100);
    }
  }

  test('walks right at the given speed', () {
    final w = Walker(alwaysWalk: true);
    run(w, 1);
    expect(w.x, closeTo(100, 1));
    expect(w.dir, 1);
  });

  test('bounces off both edges', () {
    final w = Walker(alwaysWalk: true);
    run(w, 3, maxX: 250);
    expect(w.dir, -1);
    expect(w.x, inInclusiveRange(0, 250));
    run(w, 3, maxX: 250);
    expect(w.dir, 1);
  });

  test('alternates walking and idle with prototype durations', () {
    // idle = 1.5 + .5*3.5 = 3.25 s; turn check .9 → no turn; walk = 4 + 0 = 4 s
    final w = Walker(random: _SeqRandom([.5, .9, 0]))..remaining = 1;
    run(w, 1.05);
    expect(w.mode, WalkMode.idle);
    expect(w.remaining, closeTo(3.25 - .05, .02));
    final xAtIdle = w.x;
    run(w, 3);
    expect(w.x, xAtIdle, reason: 'does not move while idle');
    run(w, .5);
    expect(w.mode, WalkMode.walking);
    expect(w.dir, 1);
  });

  test('turns around after idle when the 40% roll hits', () {
    final w = Walker(random: _SeqRandom([0, .1, 0]), initialX: 500)
      ..remaining = .01;
    run(w, .02); // → idle for 1.5 s
    run(w, 1.6); // → walking, roll .1 < .4 → turn
    expect(w.mode, WalkMode.walking);
    expect(w.dir, -1);
  });

  test('pins to minX when the area is narrower than the buddy', () {
    final w = Walker(alwaysWalk: true, initialX: 50)
      ..step(.1, minX: 10, maxX: 5, speed: 100);
    expect(w.x, 10);
  });
}
