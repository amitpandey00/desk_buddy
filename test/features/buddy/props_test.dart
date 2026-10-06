import 'dart:ui';

import 'package:desk_buddy/features/buddy/render/props.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registry has the spec props, each with a label', () {
    expect(
      propRegistry.keys,
      containsAll([
        'none',
        'bottle',
        'coffee',
        'book',
        'phone',
        'dumbbell',
        'pill',
      ]),
    );
    for (final p in propRegistry.values) {
      expect(p.label, isNotEmpty);
    }
  });

  test('"default" is reserved for "use the look\'s item"', () {
    expect(propRegistry.containsKey(defaultPropId), isFalse);
  });

  test('every prop paints without throwing', () {
    for (final p in propRegistry.values) {
      final recorder = PictureRecorder();
      p.paint(Canvas(recorder));
      recorder.endRecording().dispose();
    }
  });

  group('resolveProp', () {
    test('explicit id wins', () {
      expect(resolveProp('book', 'coffee'), same(propRegistry['book']));
    });
    test('null and "default" use the look default', () {
      expect(resolveProp(null, 'coffee'), same(propRegistry['coffee']));
      expect(resolveProp('default', 'coffee'), same(propRegistry['coffee']));
    });
    test('unknown ids degrade gracefully', () {
      expect(resolveProp('gone', 'coffee'), same(propRegistry['coffee']));
      expect(resolveProp('gone', 'also-gone'), same(propRegistry['none']));
    });
  });
}
