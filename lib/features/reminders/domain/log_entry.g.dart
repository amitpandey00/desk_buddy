// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LogEntry _$LogEntryFromJson(Map<String, dynamic> json) => _LogEntry(
  id: json['id'] as String,
  at: (json['at'] as num).toInt(),
  action: $enumDecode(_$LogActionEnumMap, json['action']),
  reminderId: json['reminderId'] as String?,
  categoryId: json['categoryId'] as String?,
  responseSeconds: (json['responseSeconds'] as num?)?.toInt() ?? 0,
  manual: json['manual'] as bool? ?? false,
  sample: json['sample'] as bool? ?? false,
);

Map<String, dynamic> _$LogEntryToJson(_LogEntry instance) => <String, dynamic>{
  'id': instance.id,
  'at': instance.at,
  'action': _$LogActionEnumMap[instance.action]!,
  'reminderId': instance.reminderId,
  'categoryId': instance.categoryId,
  'responseSeconds': instance.responseSeconds,
  'manual': instance.manual,
  'sample': instance.sample,
};

const _$LogActionEnumMap = {
  LogAction.done: 'done',
  LogAction.snoozed: 'snoozed',
  LogAction.skipped: 'skipped',
  LogAction.missed: 'missed',
};
