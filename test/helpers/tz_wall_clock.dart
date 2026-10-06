import 'package:desk_buddy/features/scheduler/engine/wall_clock.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

bool _loaded = false;

/// A [WallClock] pinned to a real IANA zone, so DST behavior is the same on
/// every machine (this one runs in IST, which has no DST).
class TzWallClock extends WallClock {
  TzWallClock(String zone) : location = _location(zone);

  final tz.Location location;

  static tz.Location _location(String zone) {
    if (!_loaded) {
      tzdata.initializeTimeZones();
      _loaded = true;
    }
    return tz.getLocation(zone);
  }

  @override
  WallTime toWall(int epochMs) {
    final t = tz.TZDateTime.fromMillisecondsSinceEpoch(location, epochMs);
    return WallTime(t.year, t.month, t.day, t.hour, t.minute, t.weekday % 7);
  }

  @override
  int rawFromWall(int year, int month, int day, int hour, int minute) =>
      tz.TZDateTime(
        location,
        year,
        month,
        day,
        hour,
        minute,
      ).millisecondsSinceEpoch;

  /// Epoch ms for a wall time in this zone (test shorthand).
  int at(int y, int m, int d, [int h = 0, int min = 0]) =>
      fromWall(y, m, d, h, min);

  /// Readable wall time of an instant (test shorthand).
  String show(int? ms) {
    if (ms == null) return 'null';
    final w = toWall(ms);
    String p(int v) => v.toString().padLeft(2, '0');
    return '${w.year}-${p(w.month)}-${p(w.day)} ${p(w.hour)}:${p(w.minute)}';
  }
}
