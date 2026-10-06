// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  userName: json['userName'] as String? ?? Strings.defaultUserName,
  buddySize: (json['buddySize'] as num?)?.toInt() ?? 120,
  walkSpeed: (json['walkSpeed'] as num?)?.toInt() ?? 45,
  walkEnabled: json['walkEnabled'] as bool? ?? true,
  buddyVisible: json['buddyVisible'] as bool? ?? true,
  soundEnabled: json['soundEnabled'] as bool? ?? true,
  snoozeMinutes: (json['snoozeMinutes'] as num?)?.toInt() ?? 10,
  autoMissMinutes: (json['autoMissMinutes'] as num?)?.toInt() ?? 5,
  doNotDisturb: json['doNotDisturb'] as bool? ?? false,
  themeMode:
      $enumDecodeNullable(_$ThemePreferenceEnumMap, json['themeMode']) ??
      ThemePreference.system,
  launchAtLogin: json['launchAtLogin'] as bool? ?? false,
  focusPopups: json['focusPopups'] as bool? ?? false,
  buddyX: (json['buddyX'] as num?)?.toDouble(),
  buddyY: (json['buddyY'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'buddySize': instance.buddySize,
      'walkSpeed': instance.walkSpeed,
      'walkEnabled': instance.walkEnabled,
      'buddyVisible': instance.buddyVisible,
      'soundEnabled': instance.soundEnabled,
      'snoozeMinutes': instance.snoozeMinutes,
      'autoMissMinutes': instance.autoMissMinutes,
      'doNotDisturb': instance.doNotDisturb,
      'themeMode': _$ThemePreferenceEnumMap[instance.themeMode]!,
      'launchAtLogin': instance.launchAtLogin,
      'focusPopups': instance.focusPopups,
      'buddyX': instance.buddyX,
      'buddyY': instance.buddyY,
    };

const _$ThemePreferenceEnumMap = {
  ThemePreference.system: 'system',
  ThemePreference.light: 'light',
  ThemePreference.dark: 'dark',
};
