import 'dart:ui';

/// Parses `#RGB`, `#RRGGBB` or `#AARRGGBB` (the `#` is optional).
/// Falls back to [fallback] for anything unparseable.
Color colorFromHex(String hex, {Color fallback = const Color(0xFF64748B)}) {
  var h = hex.trim().replaceFirst('#', '');
  if (h.length == 3) h = h.split('').map((c) => '$c$c').join();
  if (h.length == 6) h = 'FF$h';
  final v = h.length == 8 ? int.tryParse(h, radix: 16) : null;
  return v == null ? fallback : Color(v);
}

/// `#RRGGBB`, upper case. Alpha is dropped.
String colorToHex(Color c) {
  String two(double v) =>
      (v * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
  return '#${two(c.r)}${two(c.g)}${two(c.b)}';
}

/// Lightens (positive [amount]) or darkens (negative) each channel by
/// [amount] out of 255. Port of the prototype's `shade()`.
Color shade(Color c, int amount) {
  int ch(double v) => ((v * 255).round() + amount).clamp(0, 255);
  return Color.fromARGB(255, ch(c.r), ch(c.g), ch(c.b));
}
