// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reminder {

 String get id; String get title; String get categoryId; int get createdAt; int get updatedAt; String get emoji;/// Supports `{name} {title} {count} {goal} {unit} {category}`.
 String get messageTemplate; ScheduleType get scheduleType;/// interval only, ≥ 1.
 int get everyMinutes;/// interval only, `HH:mm`; null = all day. May cross midnight.
 String? get activeFrom; String? get activeTo;/// daily and once, `HH:mm`.
 String get timeOfDay;/// daily only; 0 = Sunday; empty = every day.
 List<int> get daysOfWeek;/// once only, `yyyy-MM-dd`.
 String? get date;/// 0 = no goal.
 int get dailyGoal; String get goalUnit;/// Prop registry key, or [defaultPropId] for the character's usual item.
 String get propId; String get doneLabel; bool get enabled;/// Epoch ms; null = nothing scheduled.
 int? get nextDueAt;/// Where the reminder came from. Only `local` today (calendar later).
 String get source;
/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReminderCopyWith<Reminder> get copyWith => _$ReminderCopyWithImpl<Reminder>(this as Reminder, _$identity);

  /// Serializes this Reminder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reminder&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.messageTemplate, messageTemplate) || other.messageTemplate == messageTemplate)&&(identical(other.scheduleType, scheduleType) || other.scheduleType == scheduleType)&&(identical(other.everyMinutes, everyMinutes) || other.everyMinutes == everyMinutes)&&(identical(other.activeFrom, activeFrom) || other.activeFrom == activeFrom)&&(identical(other.activeTo, activeTo) || other.activeTo == activeTo)&&(identical(other.timeOfDay, timeOfDay) || other.timeOfDay == timeOfDay)&&const DeepCollectionEquality().equals(other.daysOfWeek, daysOfWeek)&&(identical(other.date, date) || other.date == date)&&(identical(other.dailyGoal, dailyGoal) || other.dailyGoal == dailyGoal)&&(identical(other.goalUnit, goalUnit) || other.goalUnit == goalUnit)&&(identical(other.propId, propId) || other.propId == propId)&&(identical(other.doneLabel, doneLabel) || other.doneLabel == doneLabel)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.nextDueAt, nextDueAt) || other.nextDueAt == nextDueAt)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,categoryId,createdAt,updatedAt,emoji,messageTemplate,scheduleType,everyMinutes,activeFrom,activeTo,timeOfDay,const DeepCollectionEquality().hash(daysOfWeek),date,dailyGoal,goalUnit,propId,doneLabel,enabled,nextDueAt,source]);

@override
String toString() {
  return 'Reminder(id: $id, title: $title, categoryId: $categoryId, createdAt: $createdAt, updatedAt: $updatedAt, emoji: $emoji, messageTemplate: $messageTemplate, scheduleType: $scheduleType, everyMinutes: $everyMinutes, activeFrom: $activeFrom, activeTo: $activeTo, timeOfDay: $timeOfDay, daysOfWeek: $daysOfWeek, date: $date, dailyGoal: $dailyGoal, goalUnit: $goalUnit, propId: $propId, doneLabel: $doneLabel, enabled: $enabled, nextDueAt: $nextDueAt, source: $source)';
}


}

/// @nodoc
abstract mixin class $ReminderCopyWith<$Res>  {
  factory $ReminderCopyWith(Reminder value, $Res Function(Reminder) _then) = _$ReminderCopyWithImpl;
@useResult
$Res call({
 String id, String title, String categoryId, int createdAt, int updatedAt, String emoji, String messageTemplate, ScheduleType scheduleType, int everyMinutes, String? activeFrom, String? activeTo, String timeOfDay, List<int> daysOfWeek, String? date, int dailyGoal, String goalUnit, String propId, String doneLabel, bool enabled, int? nextDueAt, String source
});




}
/// @nodoc
class _$ReminderCopyWithImpl<$Res>
    implements $ReminderCopyWith<$Res> {
  _$ReminderCopyWithImpl(this._self, this._then);

  final Reminder _self;
  final $Res Function(Reminder) _then;

/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? categoryId = null,Object? createdAt = null,Object? updatedAt = null,Object? emoji = null,Object? messageTemplate = null,Object? scheduleType = null,Object? everyMinutes = null,Object? activeFrom = freezed,Object? activeTo = freezed,Object? timeOfDay = null,Object? daysOfWeek = null,Object? date = freezed,Object? dailyGoal = null,Object? goalUnit = null,Object? propId = null,Object? doneLabel = null,Object? enabled = null,Object? nextDueAt = freezed,Object? source = null,}) {
  return _then(Reminder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,messageTemplate: null == messageTemplate ? _self.messageTemplate : messageTemplate // ignore: cast_nullable_to_non_nullable
as String,scheduleType: null == scheduleType ? _self.scheduleType : scheduleType // ignore: cast_nullable_to_non_nullable
as ScheduleType,everyMinutes: null == everyMinutes ? _self.everyMinutes : everyMinutes // ignore: cast_nullable_to_non_nullable
as int,activeFrom: freezed == activeFrom ? _self.activeFrom : activeFrom // ignore: cast_nullable_to_non_nullable
as String?,activeTo: freezed == activeTo ? _self.activeTo : activeTo // ignore: cast_nullable_to_non_nullable
as String?,timeOfDay: null == timeOfDay ? _self.timeOfDay : timeOfDay // ignore: cast_nullable_to_non_nullable
as String,daysOfWeek: null == daysOfWeek ? _self.daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<int>,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,dailyGoal: null == dailyGoal ? _self.dailyGoal : dailyGoal // ignore: cast_nullable_to_non_nullable
as int,goalUnit: null == goalUnit ? _self.goalUnit : goalUnit // ignore: cast_nullable_to_non_nullable
as String,propId: null == propId ? _self.propId : propId // ignore: cast_nullable_to_non_nullable
as String,doneLabel: null == doneLabel ? _self.doneLabel : doneLabel // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,nextDueAt: freezed == nextDueAt ? _self.nextDueAt : nextDueAt // ignore: cast_nullable_to_non_nullable
as int?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Reminder].
extension ReminderPatterns on Reminder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reminder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reminder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reminder value)  $default,){
final _that = this;
switch (_that) {
case _Reminder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reminder value)?  $default,){
final _that = this;
switch (_that) {
case _Reminder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String categoryId,  int createdAt,  int updatedAt,  String emoji,  String messageTemplate,  ScheduleType scheduleType,  int everyMinutes,  String? activeFrom,  String? activeTo,  String timeOfDay,  List<int> daysOfWeek,  String? date,  int dailyGoal,  String goalUnit,  String propId,  String doneLabel,  bool enabled,  int? nextDueAt,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reminder() when $default != null:
return $default(_that.id,_that.title,_that.categoryId,_that.createdAt,_that.updatedAt,_that.emoji,_that.messageTemplate,_that.scheduleType,_that.everyMinutes,_that.activeFrom,_that.activeTo,_that.timeOfDay,_that.daysOfWeek,_that.date,_that.dailyGoal,_that.goalUnit,_that.propId,_that.doneLabel,_that.enabled,_that.nextDueAt,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String categoryId,  int createdAt,  int updatedAt,  String emoji,  String messageTemplate,  ScheduleType scheduleType,  int everyMinutes,  String? activeFrom,  String? activeTo,  String timeOfDay,  List<int> daysOfWeek,  String? date,  int dailyGoal,  String goalUnit,  String propId,  String doneLabel,  bool enabled,  int? nextDueAt,  String source)  $default,) {final _that = this;
switch (_that) {
case _Reminder():
return $default(_that.id,_that.title,_that.categoryId,_that.createdAt,_that.updatedAt,_that.emoji,_that.messageTemplate,_that.scheduleType,_that.everyMinutes,_that.activeFrom,_that.activeTo,_that.timeOfDay,_that.daysOfWeek,_that.date,_that.dailyGoal,_that.goalUnit,_that.propId,_that.doneLabel,_that.enabled,_that.nextDueAt,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String categoryId,  int createdAt,  int updatedAt,  String emoji,  String messageTemplate,  ScheduleType scheduleType,  int everyMinutes,  String? activeFrom,  String? activeTo,  String timeOfDay,  List<int> daysOfWeek,  String? date,  int dailyGoal,  String goalUnit,  String propId,  String doneLabel,  bool enabled,  int? nextDueAt,  String source)?  $default,) {final _that = this;
switch (_that) {
case _Reminder() when $default != null:
return $default(_that.id,_that.title,_that.categoryId,_that.createdAt,_that.updatedAt,_that.emoji,_that.messageTemplate,_that.scheduleType,_that.everyMinutes,_that.activeFrom,_that.activeTo,_that.timeOfDay,_that.daysOfWeek,_that.date,_that.dailyGoal,_that.goalUnit,_that.propId,_that.doneLabel,_that.enabled,_that.nextDueAt,_that.source);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reminder implements Reminder {
  const _Reminder({required this.id, required this.title, required this.categoryId, required this.createdAt, required this.updatedAt, this.emoji = Strings.defaultReminderEmoji, this.messageTemplate = '', this.scheduleType = ScheduleType.interval, this.everyMinutes = 60, this.activeFrom, this.activeTo, this.timeOfDay = '09:00',  List<int> daysOfWeek = const <int>[], this.date, this.dailyGoal = 0, this.goalUnit = '', this.propId = defaultPropId, this.doneLabel = Strings.defaultDoneLabel, this.enabled = true, this.nextDueAt, this.source = 'local'}): _daysOfWeek = daysOfWeek;
  factory _Reminder.fromJson(Map<String, dynamic> json) => _$ReminderFromJson(json);

@override final  String id;
@override final  String title;
@override final  String categoryId;
@override final  int createdAt;
@override final  int updatedAt;
@override@JsonKey() final  String emoji;
/// Supports `{name} {title} {count} {goal} {unit} {category}`.
@override@JsonKey() final  String messageTemplate;
@override@JsonKey() final  ScheduleType scheduleType;
/// interval only, ≥ 1.
@override@JsonKey() final  int everyMinutes;
/// interval only, `HH:mm`; null = all day. May cross midnight.
@override final  String? activeFrom;
@override final  String? activeTo;
/// daily and once, `HH:mm`.
@override@JsonKey() final  String timeOfDay;
/// daily only; 0 = Sunday; empty = every day.
 final  List<int> _daysOfWeek;
/// daily only; 0 = Sunday; empty = every day.
@override@JsonKey() List<int> get daysOfWeek {
  if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daysOfWeek);
}

/// once only, `yyyy-MM-dd`.
@override final  String? date;
/// 0 = no goal.
@override@JsonKey() final  int dailyGoal;
@override@JsonKey() final  String goalUnit;
/// Prop registry key, or [defaultPropId] for the character's usual item.
@override@JsonKey() final  String propId;
@override@JsonKey() final  String doneLabel;
@override@JsonKey() final  bool enabled;
/// Epoch ms; null = nothing scheduled.
@override final  int? nextDueAt;
/// Where the reminder came from. Only `local` today (calendar later).
@override@JsonKey() final  String source;

/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReminderCopyWith<_Reminder> get copyWith => __$ReminderCopyWithImpl<_Reminder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReminderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reminder&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.messageTemplate, messageTemplate) || other.messageTemplate == messageTemplate)&&(identical(other.scheduleType, scheduleType) || other.scheduleType == scheduleType)&&(identical(other.everyMinutes, everyMinutes) || other.everyMinutes == everyMinutes)&&(identical(other.activeFrom, activeFrom) || other.activeFrom == activeFrom)&&(identical(other.activeTo, activeTo) || other.activeTo == activeTo)&&(identical(other.timeOfDay, timeOfDay) || other.timeOfDay == timeOfDay)&&const DeepCollectionEquality().equals(other._daysOfWeek, _daysOfWeek)&&(identical(other.date, date) || other.date == date)&&(identical(other.dailyGoal, dailyGoal) || other.dailyGoal == dailyGoal)&&(identical(other.goalUnit, goalUnit) || other.goalUnit == goalUnit)&&(identical(other.propId, propId) || other.propId == propId)&&(identical(other.doneLabel, doneLabel) || other.doneLabel == doneLabel)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.nextDueAt, nextDueAt) || other.nextDueAt == nextDueAt)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,categoryId,createdAt,updatedAt,emoji,messageTemplate,scheduleType,everyMinutes,activeFrom,activeTo,timeOfDay,const DeepCollectionEquality().hash(_daysOfWeek),date,dailyGoal,goalUnit,propId,doneLabel,enabled,nextDueAt,source]);

@override
String toString() {
  return 'Reminder(id: $id, title: $title, categoryId: $categoryId, createdAt: $createdAt, updatedAt: $updatedAt, emoji: $emoji, messageTemplate: $messageTemplate, scheduleType: $scheduleType, everyMinutes: $everyMinutes, activeFrom: $activeFrom, activeTo: $activeTo, timeOfDay: $timeOfDay, daysOfWeek: $daysOfWeek, date: $date, dailyGoal: $dailyGoal, goalUnit: $goalUnit, propId: $propId, doneLabel: $doneLabel, enabled: $enabled, nextDueAt: $nextDueAt, source: $source)';
}


}

/// @nodoc
abstract mixin class _$ReminderCopyWith<$Res> implements $ReminderCopyWith<$Res> {
  factory _$ReminderCopyWith(_Reminder value, $Res Function(_Reminder) _then) = __$ReminderCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String categoryId, int createdAt, int updatedAt, String emoji, String messageTemplate, ScheduleType scheduleType, int everyMinutes, String? activeFrom, String? activeTo, String timeOfDay, List<int> daysOfWeek, String? date, int dailyGoal, String goalUnit, String propId, String doneLabel, bool enabled, int? nextDueAt, String source
});




}
/// @nodoc
class __$ReminderCopyWithImpl<$Res>
    implements _$ReminderCopyWith<$Res> {
  __$ReminderCopyWithImpl(this._self, this._then);

  final _Reminder _self;
  final $Res Function(_Reminder) _then;

/// Create a copy of Reminder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? categoryId = null,Object? createdAt = null,Object? updatedAt = null,Object? emoji = null,Object? messageTemplate = null,Object? scheduleType = null,Object? everyMinutes = null,Object? activeFrom = freezed,Object? activeTo = freezed,Object? timeOfDay = null,Object? daysOfWeek = null,Object? date = freezed,Object? dailyGoal = null,Object? goalUnit = null,Object? propId = null,Object? doneLabel = null,Object? enabled = null,Object? nextDueAt = freezed,Object? source = null,}) {
  return _then(_Reminder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,messageTemplate: null == messageTemplate ? _self.messageTemplate : messageTemplate // ignore: cast_nullable_to_non_nullable
as String,scheduleType: null == scheduleType ? _self.scheduleType : scheduleType // ignore: cast_nullable_to_non_nullable
as ScheduleType,everyMinutes: null == everyMinutes ? _self.everyMinutes : everyMinutes // ignore: cast_nullable_to_non_nullable
as int,activeFrom: freezed == activeFrom ? _self.activeFrom : activeFrom // ignore: cast_nullable_to_non_nullable
as String?,activeTo: freezed == activeTo ? _self.activeTo : activeTo // ignore: cast_nullable_to_non_nullable
as String?,timeOfDay: null == timeOfDay ? _self.timeOfDay : timeOfDay // ignore: cast_nullable_to_non_nullable
as String,daysOfWeek: null == daysOfWeek ? _self._daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<int>,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,dailyGoal: null == dailyGoal ? _self.dailyGoal : dailyGoal // ignore: cast_nullable_to_non_nullable
as int,goalUnit: null == goalUnit ? _self.goalUnit : goalUnit // ignore: cast_nullable_to_non_nullable
as String,propId: null == propId ? _self.propId : propId // ignore: cast_nullable_to_non_nullable
as String,doneLabel: null == doneLabel ? _self.doneLabel : doneLabel // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,nextDueAt: freezed == nextDueAt ? _self.nextDueAt : nextDueAt // ignore: cast_nullable_to_non_nullable
as int?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
