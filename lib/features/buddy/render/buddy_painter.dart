import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:desk_buddy/features/buddy/movement/buddy_pose.dart';
import 'package:desk_buddy/features/buddy/render/props.dart';
import 'package:desk_buddy/features/buddy/render/svg_path.dart';
import 'package:desk_buddy/shared/color_hex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Colors resolved from a [BuddyLook], including the derived shades.
@immutable
class BuddyPalette {
  factory BuddyPalette.of(BuddyLook look) {
    final jacket = colorFromHex(look.jacketHex);
    final pants = colorFromHex(look.pantsHex);
    final skin = colorFromHex(look.skinHex);
    final hair = colorFromHex(look.hairHex);
    return BuddyPalette._(
      skin: skin,
      hair: hair,
      jacket: jacket,
      shirt: colorFromHex(look.shirtHex),
      pants: pants,
      shoes: colorFromHex(look.shoesHex),
      jacketDark: shade(jacket, -28),
      pantsBack: shade(pants, -12),
      neck: shade(skin, -10),
      brows: shade(hair, 10),
    );
  }

  const BuddyPalette._({
    required this.skin,
    required this.hair,
    required this.jacket,
    required this.shirt,
    required this.pants,
    required this.shoes,
    required this.jacketDark,
    required this.pantsBack,
    required this.neck,
    required this.brows,
  });

  final Color skin;
  final Color hair;
  final Color jacket;
  final Color shirt;
  final Color pants;
  final Color shoes;
  final Color jacketDark;
  final Color pantsBack;
  final Color neck;
  final Color brows;
}

/// The design space every coordinate below lives in (prototype viewBox).
const buddyDesignSize = Size(120, 222);

// Shapes straight from the prototype's SVG, parsed once.
final Path _shoeFront = svgPath(
  'M40 196 Q40 188 50 188 Q60 188 60 196 Q60 202 50 202 L42 202 '
  'Q40 202 40 196Z',
);
final Path _shoeBack = svgPath(
  'M60 196 Q60 188 70 188 Q80 188 80 196 Q80 202 70 202 L62 202 '
  'Q60 202 60 196Z',
);
final Path _lapels = svgPath('M51 76 L60 92 L52 100Z M69 76 L60 92 L68 100Z');
final Path _backHairLong = svgPath(
  'M32 40 Q32 12 60 12 Q88 12 88 40 L90 80 Q60 88 30 80Z',
);
final _hair = <HairStyle, Path>{
  HairStyle.short: svgPath(
    'M35 46 Q34 16 60 16 Q87 16 85 46 Q80 30 60 29 Q41 30 35 46Z',
  ),
  HairStyle.spiky: svgPath(
    'M35 44 L37 24 L45 28 L49 13 L57 23 L64 10 L70 23 L79 15 L80 30 '
    'L86 44 Q78 30 60 30 Q42 30 35 44Z',
  ),
  HairStyle.long: svgPath(
    'M37 42 Q36 16 60 16 Q85 16 84 42 Q74 26 56 30 Q44 32 37 42Z',
  ),
};
final Path _capCrown = svgPath('M35 36 Q35 13 60 13 Q85 13 85 36Z');
final Path _capBrim = svgPath('M58 33 L97 35 Q99 40 92 40 L58 38Z');
final Path _beanie = svgPath('M34 38 Q34 9 60 9 Q86 9 86 38Z');
final Path _brows = svgPath('M46 40 Q51 37 56 40 M64 40 Q69 37 74 40');
final Path _smile = svgPath('M51 58 Q60 67 69 58');

// Sad face: brows raised in the middle, a frown, and a tear.
final Path _browsSad = svgPath('M46 41 Q51 38 56 37 M64 37 Q69 38 74 41');
final Path _frown = svgPath('M52 63 Q60 56 68 63');
final Path _tear = svgPath('M49 53 Q46.5 57.5 49 59 Q51.5 57.5 49 53Z');

const _ink = Color(0xFF1C2733);
const _white = Color(0xFFFFFFFF);

/// Paints the buddy from layered parts, in the prototype's z-order. Scales
/// the 120×222 design to whatever size it's given.
class BuddyPainter extends CustomPainter {
  BuddyPainter({
    required this.palette,
    required this.look,
    required this.prop,
    required this.pose,
    this.flip = false,
  }) : super(repaint: pose);

  final BuddyPalette palette;
  final BuddyLook look;
  final PropDef prop;
  final ValueListenable<BuddyPose> pose;

  /// Mirror horizontally (walking left).
  final bool flip;

  @override
  void paint(Canvas canvas, Size size) {
    final p = pose.value;
    final c = palette;
    canvas
      ..save()
      ..scale(size.width / buddyDesignSize.width);
    if (flip) {
      canvas
        ..translate(buddyDesignSize.width, 0)
        ..scale(-1, 1);
    }

    // Floor shadow stays put while the body bobs and hops.
    canvas
      ..drawOval(
        Rect.fromCenter(center: const Offset(60, 214), width: 60, height: 10),
        _fill(const Color.fromRGBO(0, 0, 0, .18)),
      )
      ..translate(0, p.bodyDy);

    // Legs and shoes.
    _rotated(canvas, const Offset(52, 130), p.legFront, () {
      _rrect(canvas, 45, 128, 14, 66, 6, c.pants);
      _shoe(canvas, _shoeFront);
    });
    _rotated(canvas, const Offset(68, 130), p.legBack, () {
      _rrect(canvas, 61, 128, 14, 66, 6, c.pantsBack);
      _shoe(canvas, _shoeBack);
    });

    // Back arm (swings / waves).
    _rotated(canvas, const Offset(84, 84), p.armBack, () {
      _rrect(canvas, 79, 78, 12, 50, 6, c.jacketDark);
      canvas.drawCircle(const Offset(85, 130), 6, _fill(c.skin));
    });

    // Torso, shirt, lapels, neck.
    _rrect(canvas, 35, 74, 50, 64, 14, c.jacket);
    _rrect(canvas, 51, 76, 18, 60, 3, c.shirt);
    canvas.drawPath(_lapels, _fill(c.jacketDark));
    _rrect(canvas, 54, 64, 12, 13, 4, c.neck);

    // Head.
    if (look.hairStyle == HairStyle.long) {
      canvas.drawPath(_backHairLong, _fill(c.hair));
    }
    canvas
      ..drawCircle(const Offset(35, 49), 5, _fill(c.skin))
      ..drawCircle(const Offset(85, 49), 5, _fill(c.skin))
      ..drawOval(
        Rect.fromCenter(center: const Offset(60, 46), width: 50, height: 54),
        _fill(c.skin),
      );
    final hair = _hair[look.hairStyle];
    if (hair != null) canvas.drawPath(hair, _fill(c.hair));
    switch (look.hat) {
      case HatStyle.none:
        break;
      case HatStyle.cap:
        canvas
          ..drawPath(_capCrown, _fill(c.jacket))
          ..drawPath(_capBrim, _fill(c.jacketDark));
      case HatStyle.beanie:
        canvas.drawPath(_beanie, _fill(c.jacket));
        _rrect(canvas, 33, 31, 54, 9, 4.5, c.jacketDark);
        canvas.drawCircle(const Offset(60, 9), 6, _fill(c.shirt));
    }
    canvas
      ..drawPath(p.frown > .5 ? _browsSad : _brows, _line(c.brows, 2.4))
      // Eyes (blink scales them about their center line).
      ..save()
      ..translate(60, 48)
      ..scale(1, p.eyeScaleY)
      ..translate(-60, -48)
      ..drawCircle(const Offset(51, 48), 3.2, _fill(_ink))
      ..drawCircle(const Offset(69, 48), 3.2, _fill(_ink))
      ..drawCircle(const Offset(52, 47), 1, _fill(_white))
      ..drawCircle(const Offset(70, 47), 1, _fill(_white))
      ..restore();

    if (look.spectacles) {
      final g = _line(_ink, 2)..strokeCap = StrokeCap.butt;
      canvas
        ..drawRRect(_r(43, 42, 15, 12, 4), g)
        ..drawRRect(_r(62, 42, 15, 12, 4), g)
        ..drawLine(const Offset(58, 47), const Offset(62, 47), g);
    }
    final sad = p.frown > .5;
    final cheek = Color.fromRGBO(255, 138, 128, sad ? .18 : .35);
    canvas
      ..drawCircle(const Offset(45, 57), 4, _fill(cheek))
      ..drawCircle(const Offset(75, 57), 4, _fill(cheek))
      ..drawPath(sad ? _frown : _smile, _line(const Color(0xFF6B2F1D), 2.6));
    if (sad) {
      canvas.drawPath(_tear, _fill(const Color.fromRGBO(120, 190, 255, .9)));
    }

    // Front arm with the prop, hand on top.
    _rrect(canvas, 29, 78, 12, 46, 6, c.jacket);
    prop.paint(canvas);
    canvas
      ..drawCircle(const Offset(35, 125), 6.5, _fill(c.skin))
      ..restore();
  }

  void _shoe(Canvas canvas, Path shoe) {
    canvas
      ..drawPath(shoe, _fill(palette.shoes))
      ..drawPath(shoe, _line(const Color.fromRGBO(0, 0, 0, .15), 1));
  }

  static void _rotated(
    Canvas canvas,
    Offset origin,
    double angle,
    void Function() draw,
  ) {
    if (angle == 0) return draw();
    canvas
      ..save()
      ..translate(origin.dx, origin.dy)
      ..rotate(angle)
      ..translate(-origin.dx, -origin.dy);
    draw();
    canvas.restore();
  }

  static RRect _r(double x, double y, double w, double h, double r) =>
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));

  static void _rrect(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double r,
    Color color,
  ) => canvas.drawRRect(_r(x, y, w, h, r), _fill(color));

  static Paint _fill(Color color) => Paint()..color = color;

  static Paint _line(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  @override
  bool shouldRepaint(BuddyPainter old) =>
      old.palette != palette ||
      old.look != look ||
      old.prop != prop ||
      old.flip != flip ||
      old.pose != pose;
}
