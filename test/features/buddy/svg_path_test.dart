import 'dart:ui';

import 'package:desk_buddy/features/buddy/render/svg_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('M/L/Z triangle', () {
    final p = svgPath('M51 76 L60 92 L52 100Z');
    expect(p.getBounds(), const Rect.fromLTRB(51, 76, 60, 100));
    expect(p.contains(const Offset(54, 86)), isTrue);
  });

  test('H/V and implicit lineto after M', () {
    final p = svgPath('M10 10 H30 V20 20 25Z');
    expect(p.getBounds(), const Rect.fromLTRB(10, 10, 30, 25));
  });

  test('Q curves stay inside their control hull', () {
    final p = svgPath('M51 58 Q60 67 69 58');
    final b = p.getBounds();
    expect(b.left, 51);
    expect(b.right, 69);
    expect(b.bottom, lessThanOrEqualTo(67));
    expect(b.bottom, greaterThan(58));
  });

  test('multiple subpaths', () {
    final p = svgPath('M46 40 Q51 37 56 40 M64 40 Q69 37 74 40');
    expect(p.getBounds().left, 46);
    expect(p.getBounds().right, 74);
  });

  test('rejects unsupported commands', () {
    expect(() => svgPath('M0 0 C1 1 2 2 3 3'), throwsFormatException);
  });
}
