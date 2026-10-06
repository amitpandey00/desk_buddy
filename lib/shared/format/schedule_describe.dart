import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/shared/strings.dart';

/// `19:00` → `7:00 PM` (prototype `fmt12`).
String format12h(String hm) {
  final parts = hm.split(':');
  final h = int.tryParse(parts.first) ?? 0;
  final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${m.toString().padLeft(2, '0')} '
      '${h < 12 ? Strings.am : Strings.pm}';
}

/// One-line schedule summary (prototype `describe()`):
/// "Every 60 min, 08:00–22:00", "7:00 PM, weekdays",
/// "Once on 2026-10-10 at 9:00 AM".
String describeSchedule(Reminder r) {
  switch (r.scheduleType) {
    case ScheduleType.interval:
      final window = r.activeFrom != null && r.activeTo != null
          ? ', ${r.activeFrom}–${r.activeTo}'
          : '';
      return '${Strings.every} ${r.everyMinutes} ${Strings.minutesShort}'
          '$window';
    case ScheduleType.daily:
      final days = [
        ...{...r.daysOfWeek},
      ]..sort();
      final String when;
      if (days.isEmpty || days.length == 7) {
        when = Strings.everyDay;
      } else if (days.join() == '12345') {
        when = Strings.weekdays;
      } else if (days.join() == '06') {
        when = Strings.weekends;
      } else {
        when = days.map((d) => Strings.dayShort[d % 7]).join(', ');
      }
      return '${format12h(r.timeOfDay)}, $when';
    case ScheduleType.once:
      return Strings.onceOn(r.date ?? Strings.none, format12h(r.timeOfDay));
  }
}
