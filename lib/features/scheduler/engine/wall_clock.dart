/// A local calendar date and time of day. [weekday] is 0 = Sunday … 6.
class WallTime {
  const WallTime(
    this.year,
    this.month,
    this.day,
    this.hour,
    this.minute,
    this.weekday,
  );

  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int weekday;

  int get minuteOfDay => hour * 60 + minute;

  /// Orders wall times without involving any time zone.
  int get sortKey =>
      DateTime.utc(year, month, day, hour, minute).millisecondsSinceEpoch;

  @override
  String toString() =>
      '$year-${_pad(month)}-${_pad(day)} '
      '${_pad(hour)}:${_pad(minute)} (wd $weekday)';

  static String _pad(int v) => v.toString().padLeft(2, '0');
}

/// Converts between instants (epoch ms) and local wall time.
///
/// All scheduling goes through this, so tests can pin a real DST zone and
/// the engine never adds "a day" as 24 hours.
abstract class WallClock {
  const WallClock();

  WallTime toWall(int epochMs);

  /// The platform's raw conversion (subclasses).
  int rawFromWall(int year, int month, int day, int hour, int minute);

  /// The instant showing this wall time. Out-of-range fields roll over
  /// (day 32 → next month). A time skipped by a DST jump resolves forward by
  /// the jump (02:30 → 03:30); a time that happens twice resolves to the
  /// earlier instant.
  int fromWall(int year, int month, int day, [int hour = 0, int minute = 0]) {
    final n = DateTime.utc(year, month, day, hour, minute);
    final want = DateTime.utc(
      n.year,
      n.month,
      n.day,
      n.hour,
      n.minute,
    ).millisecondsSinceEpoch;
    var ms = rawFromWall(n.year, n.month, n.day, n.hour, n.minute);
    // Ambiguous (fall back): prefer the earlier instant if it shows the same.
    const hour1 = Duration.millisecondsPerHour;
    if (toWall(ms - hour1).sortKey == want) ms -= hour1;
    // Nonexistent (spring forward): land after the gap, never before it.
    if (toWall(ms).sortKey < want) ms += hour1;
    return ms;
  }

  /// Local midnight of the day containing [epochMs].
  int startOfDay(int epochMs) {
    final w = toWall(epochMs);
    return fromWall(w.year, w.month, w.day);
  }

  /// Local midnight [days] calendar days after the day of [epochMs].
  int startOfDayOffset(int epochMs, int days) {
    final w = toWall(epochMs);
    return fromWall(w.year, w.month, w.day + days);
  }
}

/// The machine's time zone, via `DateTime`.
class LocalWallClock extends WallClock {
  const LocalWallClock();

  @override
  WallTime toWall(int epochMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return WallTime(d.year, d.month, d.day, d.hour, d.minute, d.weekday % 7);
  }

  @override
  int rawFromWall(int year, int month, int day, int hour, int minute) =>
      DateTime(year, month, day, hour, minute).millisecondsSinceEpoch;
}
