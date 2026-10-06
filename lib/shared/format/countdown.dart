import 'package:desk_buddy/shared/strings.dart';

/// "now", "45s", "12 min", "3h 5m", "2d" — the prototype's `fmtIn`.
String formatCountdown(int ms) {
  if (ms <= 0) return Strings.countdownNow;
  final s = (ms / 1000).round();
  if (s < 60) return Strings.countdownSeconds(s);
  final m = s ~/ 60;
  if (m < 60) return Strings.countdownMinutes(m);
  final h = m ~/ 60;
  if (h < 24) return Strings.countdownHours(h, m % 60);
  return Strings.countdownDays(h ~/ 24);
}
