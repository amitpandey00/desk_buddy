import 'package:desk_buddy/features/buddy/domain/prop_ids.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

enum ScheduleType { interval, daily, once }

/// Anything the user wants a nudge for. Every behavior — when it fires, what
/// the buddy says and holds, how it counts toward a goal — comes from these
/// fields; nothing in the app special-cases a particular reminder.
@freezed
abstract class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    required String title,
    required String categoryId,
    required int createdAt,
    required int updatedAt,
    @Default(Strings.defaultReminderEmoji) String emoji,

    /// Supports `{name} {title} {count} {goal} {unit} {category}`.
    @Default('') String messageTemplate,
    @Default(ScheduleType.interval) ScheduleType scheduleType,

    /// interval only, ≥ 1.
    @Default(60) int everyMinutes,

    /// interval only, `HH:mm`; null = all day. May cross midnight.
    String? activeFrom,
    String? activeTo,

    /// daily and once, `HH:mm`.
    @Default('09:00') String timeOfDay,

    /// daily only; 0 = Sunday; empty = every day.
    @Default(<int>[]) List<int> daysOfWeek,

    /// once only, `yyyy-MM-dd`.
    String? date,

    /// 0 = no goal.
    @Default(0) int dailyGoal,
    @Default('') String goalUnit,

    /// Prop registry key, or [defaultPropId] for the character's usual item.
    @Default(defaultPropId) String propId,
    @Default(Strings.defaultDoneLabel) String doneLabel,
    @Default(true) bool enabled,

    /// Epoch ms; null = nothing scheduled.
    int? nextDueAt,

    /// Where the reminder came from. Only `local` today (calendar later).
    @Default('local') String source,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
