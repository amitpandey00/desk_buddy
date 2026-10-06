// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reminder _$ReminderFromJson(Map<String, dynamic> json) => _Reminder(
  id: json['id'] as String,
  title: json['title'] as String,
  categoryId: json['categoryId'] as String,
  createdAt: (json['createdAt'] as num).toInt(),
  updatedAt: (json['updatedAt'] as num).toInt(),
  emoji: json['emoji'] as String? ?? Strings.defaultReminderEmoji,
  messageTemplate: json['messageTemplate'] as String? ?? '',
  scheduleType:
      $enumDecodeNullable(_$ScheduleTypeEnumMap, json['scheduleType']) ??
      ScheduleType.interval,
  everyMinutes: (json['everyMinutes'] as num?)?.toInt() ?? 60,
  activeFrom: json['activeFrom'] as String?,
  activeTo: json['activeTo'] as String?,
  timeOfDay: json['timeOfDay'] as String? ?? '09:00',
  daysOfWeek:
      (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  date: json['date'] as String?,
  dailyGoal: (json['dailyGoal'] as num?)?.toInt() ?? 0,
  goalUnit: json['goalUnit'] as String? ?? '',
  propId: json['propId'] as String? ?? defaultPropId,
  doneLabel: json['doneLabel'] as String? ?? Strings.defaultDoneLabel,
  enabled: json['enabled'] as bool? ?? true,
  nextDueAt: (json['nextDueAt'] as num?)?.toInt(),
  source: json['source'] as String? ?? 'local',
);

Map<String, dynamic> _$ReminderToJson(_Reminder instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'categoryId': instance.categoryId,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'emoji': instance.emoji,
  'messageTemplate': instance.messageTemplate,
  'scheduleType': _$ScheduleTypeEnumMap[instance.scheduleType]!,
  'everyMinutes': instance.everyMinutes,
  'activeFrom': instance.activeFrom,
  'activeTo': instance.activeTo,
  'timeOfDay': instance.timeOfDay,
  'daysOfWeek': instance.daysOfWeek,
  'date': instance.date,
  'dailyGoal': instance.dailyGoal,
  'goalUnit': instance.goalUnit,
  'propId': instance.propId,
  'doneLabel': instance.doneLabel,
  'enabled': instance.enabled,
  'nextDueAt': instance.nextDueAt,
  'source': instance.source,
};

const _$ScheduleTypeEnumMap = {
  ScheduleType.interval: 'interval',
  ScheduleType.daily: 'daily',
  ScheduleType.once: 'once',
};
