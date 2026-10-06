import 'package:desk_buddy/features/buddy/domain/prop_ids.dart';
import 'package:desk_buddy/features/reminders/domain/reminder.dart';
import 'package:desk_buddy/shared/strings.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'starter.freezed.dart';
part 'starter.g.dart';

/// A one-tap template from `assets/seed/starters.json`. Starters are data:
/// the user edits or deletes the resulting reminder like any other.
@freezed
abstract class Starter with _$Starter {
  const factory Starter({
    required String title,

    /// Category *name*; resolved (or created) when the starter is used.
    required String category,
    @Default(Strings.defaultReminderEmoji) String emoji,
    @Default('') String messageTemplate,
    @Default(ScheduleType.interval) ScheduleType scheduleType,
    @Default(60) int everyMinutes,
    String? activeFrom,
    String? activeTo,
    @Default('09:00') String timeOfDay,
    @Default(<int>[]) List<int> daysOfWeek,
    String? date,
    @Default(0) int dailyGoal,
    @Default('') String goalUnit,
    @Default(defaultPropId) String propId,
    @Default(Strings.defaultDoneLabel) String doneLabel,
  }) = _Starter;

  const Starter._();

  factory Starter.fromJson(Map<String, dynamic> json) =>
      _$StarterFromJson(json);

  /// A new reminder from this template, in [categoryId], not yet scheduled.
  Reminder toReminder({
    required String id,
    required String categoryId,
    required int now,
  }) => Reminder(
    id: id,
    title: title,
    categoryId: categoryId,
    createdAt: now,
    updatedAt: now,
    emoji: emoji,
    messageTemplate: messageTemplate,
    scheduleType: scheduleType,
    everyMinutes: everyMinutes,
    activeFrom: activeFrom,
    activeTo: activeTo,
    timeOfDay: timeOfDay,
    daysOfWeek: daysOfWeek,
    date: date,
    dailyGoal: dailyGoal,
    goalUnit: goalUnit,
    propId: propId,
    doneLabel: doneLabel,
  );
}
