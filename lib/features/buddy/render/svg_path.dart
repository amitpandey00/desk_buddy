import 'dart:ui';

final _token = RegExp(r'[A-Za-z]|-?\d*\.?\d+(?:e-?\d+)?');

/// Builds a [Path] from the subset of SVG path syntax the character uses:
/// absolute `M L H V Q Z`. Keeps the painter's shapes byte-for-byte
/// identical to the prototype's SVG.
Path svgPath(String d) {
  final tokens = _token.allMatches(d).map((m) => m.group(0)!).toList();
  final path = Path();
  var i = 0;
  var cmd = 'M';
  var x = 0.0;
  var y = 0.0;
  double n() => double.parse(tokens[i++]);
  bool isCmd(String t) => RegExp('[A-Za-z]').hasMatch(t);

  while (i < tokens.length) {
    if (isCmd(tokens[i])) cmd = tokens[i++];
    switch (cmd) {
      case 'M':
        x = n();
        y = n();
        path.moveTo(x, y);
        cmd = 'L'; // implicit lineto for following pairs
      case 'L':
        x = n();
        y = n();
        path.lineTo(x, y);
      case 'H':
        x = n();
        path.lineTo(x, y);
      case 'V':
        y = n();
        path.lineTo(x, y);
      case 'Q':
        final cx = n();
        final cy = n();
        x = n();
        y = n();
        path.quadraticBezierTo(cx, cy, x, y);
      case 'Z' || 'z':
        path.close();
        if (i < tokens.length && !isCmd(tokens[i])) {
          throw FormatException('Numbers after Z', d);
        }
      default:
        throw FormatException('Unsupported SVG path command "$cmd"', d);
    }
  }
  return path;
}
