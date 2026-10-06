import 'dart:ui';

import 'package:desk_buddy/features/buddy/domain/prop_ids.dart';

export 'package:desk_buddy/features/buddy/domain/prop_ids.dart';

/// Paints a prop in the buddy's 120×222 design space, inside the front arm
/// (it moves with the arm). The hand is painted on top afterwards.
typedef PropPainter = void Function(Canvas canvas);

class PropDef {
  const PropDef(this.label, this.paint);

  /// Shown in "Buddy holds" / "Usually holding" pickers.
  final String label;
  final PropPainter paint;
}

/// Every prop the buddy can hold. **Adding a prop = adding an entry here.**
/// Nothing else in the app refers to a specific prop.
final Map<String, PropDef> propRegistry = {
  'none': PropDef('Nothing', (_) {}),
  'bottle': PropDef('Bottle', (c) {
    _rect(c, 27, 98, 14, 30, 4, const Color.fromRGBO(190, 225, 255, .75));
    _rect(c, 27, 98, 14, 30, 4, const Color(0xFF9CC6EC), stroke: 1.5);
    _rect(c, 28, 110, 12, 16, 3, const Color.fromRGBO(80, 160, 240, .55));
    _rect(c, 30, 93, 8, 6, 1.5, const Color(0xFFE8473A));
  }),
  'coffee': PropDef('Coffee', (c) {
    final cup = Path()
      ..moveTo(26, 111)
      ..lineTo(42, 111)
      ..lineTo(40, 130)
      ..lineTo(28, 130)
      ..close();
    c
      ..drawPath(cup, Paint()..color = const Color(0xFFFFFFFF))
      ..drawPath(cup, _stroke(const Color(0xFFC8CDD3), 1.2));
    _rect(c, 25, 108, 18, 4, 2, const Color(0xFF5B4636));
    _rect(c, 27, 117, 14, 6, 0, const Color(0xFFB07A4F));
  }),
  'book': PropDef('Book', (c) {
    _rect(c, 22, 104, 24, 20, 2, const Color(0xFFE8473A));
    _rect(c, 24, 106, 20, 16, 0, const Color(0xFFFFF8E7));
    c.drawLine(
      const Offset(34, 106),
      const Offset(34, 122),
      _stroke(const Color(0xFFE8473A), 1.5),
    );
  }),
  'phone': PropDef('Phone', (c) {
    _rect(c, 28, 102, 14, 24, 3, const Color(0xFF1C2733));
    _rect(c, 30, 105, 10, 17, 1.5, const Color(0xFF7FB8F0));
  }),
  'dumbbell': PropDef('Dumbbell', (c) {
    _rect(c, 22, 123, 26, 4, 2, const Color(0xFF666666));
    _rect(c, 17, 116, 8, 18, 2, const Color(0xFF333333));
    _rect(c, 45, 116, 8, 18, 2, const Color(0xFF333333));
  }),
  'pill': PropDef('Pill box', (c) {
    _rect(c, 24, 110, 22, 14, 4, const Color(0xFFFFFFFF));
    _rect(c, 24, 110, 22, 14, 4, const Color(0xFFC8CDD3), stroke: 1);
    _rect(c, 24, 110, 11, 14, 4, const Color(0xFF8B5CF6));
  }),
};

/// Resolves a reminder's prop: `default` (or an unknown id) falls back to
/// the character's usual item, which itself falls back to nothing.
PropDef resolveProp(String? propId, String lookDefault) {
  final id = (propId == null || propId == defaultPropId) ? lookDefault : propId;
  return propRegistry[id] ?? propRegistry[lookDefault] ?? propRegistry['none']!;
}

Paint _stroke(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width;

void _rect(
  Canvas c,
  double x,
  double y,
  double w,
  double h,
  double r,
  Color color, {
  double? stroke,
}) {
  c.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
    stroke == null ? (Paint()..color = color) : _stroke(color, stroke),
  );
}
