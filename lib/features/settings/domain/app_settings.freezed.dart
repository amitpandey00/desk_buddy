// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

/// Fills `{name}`.
 String get userName;/// Logical px wide, [sizeMin]–[sizeMax].
 int get buddySize;/// px per second, [speedMin]–[speedMax].
 int get walkSpeed; bool get walkEnabled; bool get buddyVisible; bool get soundEnabled;/// One of [snoozeOptions].
 int get snoozeMinutes;/// One of [autoMissOptions].
 int get autoMissMinutes; bool get doNotDisturb; ThemePreference get themeMode; bool get launchAtLogin;/// Give a pop-up keyboard focus (so Enter answers it). Off by default:
/// otherwise a reminder would grab the keys you're typing. Forced on
/// while a screen reader is running.
 bool get focusPopups;/// Buddy top-left in physical virtual-screen px; null = default spot.
 double? get buddyX; double? get buddyY;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.buddySize, buddySize) || other.buddySize == buddySize)&&(identical(other.walkSpeed, walkSpeed) || other.walkSpeed == walkSpeed)&&(identical(other.walkEnabled, walkEnabled) || other.walkEnabled == walkEnabled)&&(identical(other.buddyVisible, buddyVisible) || other.buddyVisible == buddyVisible)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.snoozeMinutes, snoozeMinutes) || other.snoozeMinutes == snoozeMinutes)&&(identical(other.autoMissMinutes, autoMissMinutes) || other.autoMissMinutes == autoMissMinutes)&&(identical(other.doNotDisturb, doNotDisturb) || other.doNotDisturb == doNotDisturb)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.launchAtLogin, launchAtLogin) || other.launchAtLogin == launchAtLogin)&&(identical(other.focusPopups, focusPopups) || other.focusPopups == focusPopups)&&(identical(other.buddyX, buddyX) || other.buddyX == buddyX)&&(identical(other.buddyY, buddyY) || other.buddyY == buddyY));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userName,buddySize,walkSpeed,walkEnabled,buddyVisible,soundEnabled,snoozeMinutes,autoMissMinutes,doNotDisturb,themeMode,launchAtLogin,focusPopups,buddyX,buddyY);

@override
String toString() {
  return 'AppSettings(userName: $userName, buddySize: $buddySize, walkSpeed: $walkSpeed, walkEnabled: $walkEnabled, buddyVisible: $buddyVisible, soundEnabled: $soundEnabled, snoozeMinutes: $snoozeMinutes, autoMissMinutes: $autoMissMinutes, doNotDisturb: $doNotDisturb, themeMode: $themeMode, launchAtLogin: $launchAtLogin, focusPopups: $focusPopups, buddyX: $buddyX, buddyY: $buddyY)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 String userName, int buddySize, int walkSpeed, bool walkEnabled, bool buddyVisible, bool soundEnabled, int snoozeMinutes, int autoMissMinutes, bool doNotDisturb, ThemePreference themeMode, bool launchAtLogin, bool focusPopups, double? buddyX, double? buddyY
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userName = null,Object? buddySize = null,Object? walkSpeed = null,Object? walkEnabled = null,Object? buddyVisible = null,Object? soundEnabled = null,Object? snoozeMinutes = null,Object? autoMissMinutes = null,Object? doNotDisturb = null,Object? themeMode = null,Object? launchAtLogin = null,Object? focusPopups = null,Object? buddyX = freezed,Object? buddyY = freezed,}) {
  return _then(AppSettings(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,buddySize: null == buddySize ? _self.buddySize : buddySize // ignore: cast_nullable_to_non_nullable
as int,walkSpeed: null == walkSpeed ? _self.walkSpeed : walkSpeed // ignore: cast_nullable_to_non_nullable
as int,walkEnabled: null == walkEnabled ? _self.walkEnabled : walkEnabled // ignore: cast_nullable_to_non_nullable
as bool,buddyVisible: null == buddyVisible ? _self.buddyVisible : buddyVisible // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,snoozeMinutes: null == snoozeMinutes ? _self.snoozeMinutes : snoozeMinutes // ignore: cast_nullable_to_non_nullable
as int,autoMissMinutes: null == autoMissMinutes ? _self.autoMissMinutes : autoMissMinutes // ignore: cast_nullable_to_non_nullable
as int,doNotDisturb: null == doNotDisturb ? _self.doNotDisturb : doNotDisturb // ignore: cast_nullable_to_non_nullable
as bool,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemePreference,launchAtLogin: null == launchAtLogin ? _self.launchAtLogin : launchAtLogin // ignore: cast_nullable_to_non_nullable
as bool,focusPopups: null == focusPopups ? _self.focusPopups : focusPopups // ignore: cast_nullable_to_non_nullable
as bool,buddyX: freezed == buddyX ? _self.buddyX : buddyX // ignore: cast_nullable_to_non_nullable
as double?,buddyY: freezed == buddyY ? _self.buddyY : buddyY // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userName,  int buddySize,  int walkSpeed,  bool walkEnabled,  bool buddyVisible,  bool soundEnabled,  int snoozeMinutes,  int autoMissMinutes,  bool doNotDisturb,  ThemePreference themeMode,  bool launchAtLogin,  bool focusPopups,  double? buddyX,  double? buddyY)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.userName,_that.buddySize,_that.walkSpeed,_that.walkEnabled,_that.buddyVisible,_that.soundEnabled,_that.snoozeMinutes,_that.autoMissMinutes,_that.doNotDisturb,_that.themeMode,_that.launchAtLogin,_that.focusPopups,_that.buddyX,_that.buddyY);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userName,  int buddySize,  int walkSpeed,  bool walkEnabled,  bool buddyVisible,  bool soundEnabled,  int snoozeMinutes,  int autoMissMinutes,  bool doNotDisturb,  ThemePreference themeMode,  bool launchAtLogin,  bool focusPopups,  double? buddyX,  double? buddyY)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.userName,_that.buddySize,_that.walkSpeed,_that.walkEnabled,_that.buddyVisible,_that.soundEnabled,_that.snoozeMinutes,_that.autoMissMinutes,_that.doNotDisturb,_that.themeMode,_that.launchAtLogin,_that.focusPopups,_that.buddyX,_that.buddyY);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userName,  int buddySize,  int walkSpeed,  bool walkEnabled,  bool buddyVisible,  bool soundEnabled,  int snoozeMinutes,  int autoMissMinutes,  bool doNotDisturb,  ThemePreference themeMode,  bool launchAtLogin,  bool focusPopups,  double? buddyX,  double? buddyY)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.userName,_that.buddySize,_that.walkSpeed,_that.walkEnabled,_that.buddyVisible,_that.soundEnabled,_that.snoozeMinutes,_that.autoMissMinutes,_that.doNotDisturb,_that.themeMode,_that.launchAtLogin,_that.focusPopups,_that.buddyX,_that.buddyY);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings extends AppSettings {
  const _AppSettings({this.userName = Strings.defaultUserName, this.buddySize = 120, this.walkSpeed = 45, this.walkEnabled = true, this.buddyVisible = true, this.soundEnabled = true, this.snoozeMinutes = 10, this.autoMissMinutes = 5, this.doNotDisturb = false, this.themeMode = ThemePreference.system, this.launchAtLogin = false, this.focusPopups = false, this.buddyX, this.buddyY}): super._();
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

/// Fills `{name}`.
@override@JsonKey() final  String userName;
/// Logical px wide, [sizeMin]–[sizeMax].
@override@JsonKey() final  int buddySize;
/// px per second, [speedMin]–[speedMax].
@override@JsonKey() final  int walkSpeed;
@override@JsonKey() final  bool walkEnabled;
@override@JsonKey() final  bool buddyVisible;
@override@JsonKey() final  bool soundEnabled;
/// One of [snoozeOptions].
@override@JsonKey() final  int snoozeMinutes;
/// One of [autoMissOptions].
@override@JsonKey() final  int autoMissMinutes;
@override@JsonKey() final  bool doNotDisturb;
@override@JsonKey() final  ThemePreference themeMode;
@override@JsonKey() final  bool launchAtLogin;
/// Give a pop-up keyboard focus (so Enter answers it). Off by default:
/// otherwise a reminder would grab the keys you're typing. Forced on
/// while a screen reader is running.
@override@JsonKey() final  bool focusPopups;
/// Buddy top-left in physical virtual-screen px; null = default spot.
@override final  double? buddyX;
@override final  double? buddyY;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.buddySize, buddySize) || other.buddySize == buddySize)&&(identical(other.walkSpeed, walkSpeed) || other.walkSpeed == walkSpeed)&&(identical(other.walkEnabled, walkEnabled) || other.walkEnabled == walkEnabled)&&(identical(other.buddyVisible, buddyVisible) || other.buddyVisible == buddyVisible)&&(identical(other.soundEnabled, soundEnabled) || other.soundEnabled == soundEnabled)&&(identical(other.snoozeMinutes, snoozeMinutes) || other.snoozeMinutes == snoozeMinutes)&&(identical(other.autoMissMinutes, autoMissMinutes) || other.autoMissMinutes == autoMissMinutes)&&(identical(other.doNotDisturb, doNotDisturb) || other.doNotDisturb == doNotDisturb)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.launchAtLogin, launchAtLogin) || other.launchAtLogin == launchAtLogin)&&(identical(other.focusPopups, focusPopups) || other.focusPopups == focusPopups)&&(identical(other.buddyX, buddyX) || other.buddyX == buddyX)&&(identical(other.buddyY, buddyY) || other.buddyY == buddyY));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userName,buddySize,walkSpeed,walkEnabled,buddyVisible,soundEnabled,snoozeMinutes,autoMissMinutes,doNotDisturb,themeMode,launchAtLogin,focusPopups,buddyX,buddyY);

@override
String toString() {
  return 'AppSettings(userName: $userName, buddySize: $buddySize, walkSpeed: $walkSpeed, walkEnabled: $walkEnabled, buddyVisible: $buddyVisible, soundEnabled: $soundEnabled, snoozeMinutes: $snoozeMinutes, autoMissMinutes: $autoMissMinutes, doNotDisturb: $doNotDisturb, themeMode: $themeMode, launchAtLogin: $launchAtLogin, focusPopups: $focusPopups, buddyX: $buddyX, buddyY: $buddyY)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 String userName, int buddySize, int walkSpeed, bool walkEnabled, bool buddyVisible, bool soundEnabled, int snoozeMinutes, int autoMissMinutes, bool doNotDisturb, ThemePreference themeMode, bool launchAtLogin, bool focusPopups, double? buddyX, double? buddyY
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userName = null,Object? buddySize = null,Object? walkSpeed = null,Object? walkEnabled = null,Object? buddyVisible = null,Object? soundEnabled = null,Object? snoozeMinutes = null,Object? autoMissMinutes = null,Object? doNotDisturb = null,Object? themeMode = null,Object? launchAtLogin = null,Object? focusPopups = null,Object? buddyX = freezed,Object? buddyY = freezed,}) {
  return _then(_AppSettings(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,buddySize: null == buddySize ? _self.buddySize : buddySize // ignore: cast_nullable_to_non_nullable
as int,walkSpeed: null == walkSpeed ? _self.walkSpeed : walkSpeed // ignore: cast_nullable_to_non_nullable
as int,walkEnabled: null == walkEnabled ? _self.walkEnabled : walkEnabled // ignore: cast_nullable_to_non_nullable
as bool,buddyVisible: null == buddyVisible ? _self.buddyVisible : buddyVisible // ignore: cast_nullable_to_non_nullable
as bool,soundEnabled: null == soundEnabled ? _self.soundEnabled : soundEnabled // ignore: cast_nullable_to_non_nullable
as bool,snoozeMinutes: null == snoozeMinutes ? _self.snoozeMinutes : snoozeMinutes // ignore: cast_nullable_to_non_nullable
as int,autoMissMinutes: null == autoMissMinutes ? _self.autoMissMinutes : autoMissMinutes // ignore: cast_nullable_to_non_nullable
as int,doNotDisturb: null == doNotDisturb ? _self.doNotDisturb : doNotDisturb // ignore: cast_nullable_to_non_nullable
as bool,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemePreference,launchAtLogin: null == launchAtLogin ? _self.launchAtLogin : launchAtLogin // ignore: cast_nullable_to_non_nullable
as bool,focusPopups: null == focusPopups ? _self.focusPopups : focusPopups // ignore: cast_nullable_to_non_nullable
as bool,buddyX: freezed == buddyX ? _self.buddyX : buddyX // ignore: cast_nullable_to_non_nullable
as double?,buddyY: freezed == buddyY ? _self.buddyY : buddyY // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
