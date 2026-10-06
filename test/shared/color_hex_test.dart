import 'dart:ui';

import 'package:desk_buddy/shared/color_hex.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses #RRGGBB, #RGB, no hash, and #AARRGGBB', () {
    expect(colorFromHex('#4E7FB8'), const Color(0xFF4E7FB8));
    expect(colorFromHex('#fff'), const Color(0xFFFFFFFF));
    expect(colorFromHex('1fa97f'), const Color(0xFF1FA97F));
    expect(colorFromHex('#801C2733'), const Color(0x801C2733));
  });

  test('falls back on junk', () {
    expect(colorFromHex('nope'), const Color(0xFF64748B));
    expect(colorFromHex('', fallback: const Color(0xFF000000)), isNotNull);
  });

  test('round-trips to upper-case #RRGGBB', () {
    expect(colorToHex(colorFromHex('#4e7fb8')), '#4E7FB8');
  });

  test("shade() matches the prototype's per-channel math", () {
    // Prototype: shade('#4E7FB8', -28) → #32639c
    expect(colorToHex(shade(colorFromHex('#4E7FB8'), -28)), '#32639C');
    // Clamps at both ends.
    expect(colorToHex(shade(colorFromHex('#101010'), -40)), '#000000');
    expect(colorToHex(shade(colorFromHex('#F4F4F4'), 40)), '#FFFFFF');
  });
}
