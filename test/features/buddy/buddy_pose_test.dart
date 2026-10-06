import 'dart:math';

import 'package:desk_buddy/features/buddy/movement/buddy_pose.dart';
import 'package:flutter_test/flutter_test.dart';

double deg(double rad) => rad * 180 / pi;

void main() {
  group('walking', () {
    test('legs swing ±16° in opposition on a 1 s cycle', () {
      final start = poseAt(BuddyState.walking, 0);
      final mid = poseAt(BuddyState.walking, .5);
      expect(deg(start.legFront), closeTo(-16, 1e-9));
      expect(deg(start.legBack), closeTo(16, 1e-9));
      expect(deg(mid.legFront), closeTo(16, 1e-9));
      expect(deg(mid.legBack), closeTo(-16, 1e-9));
      expect(deg(poseAt(BuddyState.walking, 1).legFront), closeTo(-16, 1e-9));
    });

    test('back arm follows the front leg', () {
      final p = poseAt(BuddyState.walking, .3);
      expect(p.armBack, p.legFront);
    });

    test('body bobs 0 → -3 px every 0.25 s', () {
      expect(poseAt(BuddyState.walking, 0).bodyDy, closeTo(0, 1e-9));
      expect(poseAt(BuddyState.walking, .25).bodyDy, closeTo(-3, 1e-9));
      expect(poseAt(BuddyState.walking, .5).bodyDy, closeTo(0, 1e-9));
    });
  });

  group('idle & dragging', () {
    test('breathe 1.5 px over 2.4 s, limbs at rest', () {
      for (final s in [BuddyState.idle, BuddyState.dragging]) {
        expect(poseAt(s, 0).bodyDy, closeTo(0, 1e-9));
        expect(poseAt(s, 1.2).bodyDy, closeTo(-1.5, 1e-9));
        expect(poseAt(s, 2.4).bodyDy, closeTo(0, 1e-9));
        expect(poseAt(s, .7).legFront, 0);
        expect(poseAt(s, .7).armBack, 0);
      }
    });
  });

  group('alert', () {
    test('hops 9 px at 30% of a 0.9 s cycle and rests from 60%', () {
      expect(poseAt(BuddyState.alert, .27).bodyDy, closeTo(-9, 1e-9));
      expect(poseAt(BuddyState.alert, .405).bodyDy, closeTo(-4.5, 1e-9));
      expect(poseAt(BuddyState.alert, .7).bodyDy, 0);
    });

    test('back arm waves between -165° and -125°', () {
      expect(deg(poseAt(BuddyState.alert, 0).armBack), closeTo(-165, 1e-9));
      expect(deg(poseAt(BuddyState.alert, .45).armBack), closeTo(-125, 1e-9));
      for (var t = 0.0; t < 2; t += .03) {
        expect(
          deg(poseAt(BuddyState.alert, t).armBack),
          inInclusiveRange(-165, -125),
        );
      }
    });
  });

  test('sad: slumped, droopy eyes, frowning, still blinking', () {
    final p = poseAt(BuddyState.sad, 1);
    expect(p.frown, 1);
    expect(p.bodyDy, greaterThan(2.4), reason: 'lower than standing');
    expect(p.eyeScaleY, closeTo(.7, 1e-9));
    expect(poseAt(BuddyState.sad, 4.5 * .96).eyeScaleY, closeTo(.07, 1e-9));
    expect(poseAt(BuddyState.idle, 1).frown, 0);
    expect(poseAt(BuddyState.sad, 1, reduceMotion: true).frown, 1);
  });

  test('eyes blink near the end of every 4.5 s, in every state', () {
    for (final s in BuddyState.values) {
      // Sad eyes are half-lidded; the blink is relative to how open they are.
      final open = poseAt(s, 1).eyeScaleY;
      expect(open, s == BuddyState.sad ? .7 : 1);
      expect(poseAt(s, 4.5 * .96).eyeScaleY, closeTo(open * .1, 1e-9));
      expect(poseAt(s, 4.5 + 1).eyeScaleY, open);
    }
  });

  test('reduce motion: nothing loops, alert keeps a raised arm', () {
    for (final t in [0.0, .3, 1.7, 4.32]) {
      final idle = poseAt(BuddyState.walking, t, reduceMotion: true);
      expect(idle.legFront, 0);
      expect(idle.bodyDy, 0);
      expect(idle.eyeScaleY, 1);
      final alert = poseAt(BuddyState.alert, t, reduceMotion: true);
      expect(deg(alert.armBack), closeTo(-145, 1e-9));
      expect(alert.bodyDy, 0);
    }
  });
}
