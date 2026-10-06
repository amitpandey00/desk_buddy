// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'starter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Starter {

 String get title;/// Category *name*; resolved (or created) when the starter is used.
 String get category; String get emoji; String get messageTemplate; ScheduleType get scheduleType; int get everyMinutes; String? get activeFrom; String? get activeTo; String get timeOfDay; List<int> get daysOfWeek; String? get date; int get dailyGoal; String get goalUnit; String get propId; String get doneLabel;
/// Create a copy of Starter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StarterCopyWith<Starter> get copyWith => _$StarterCopyWithImpl<Starter>(this as Starter, _$identity);

  /// Serializes this Starter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Starter&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.messageTemplate, messageTemplate) || other.messageTemplate == messageTemplate)&&(identical(other.scheduleType, scheduleType) || other.scheduleType == scheduleType)&&(identical(other.everyMinutes, everyMinutes) || other.everyMinutes == everyMinutes)&&(identical(other.activeFrom, activeFrom) || other.activeFrom == activeFrom)&&(identical(other.activeTo, activeTo) || other.activeTo == activeTo)&&(identical(other.timeOfDay, timeOfDay) || other.timeOfDay == timeOfDay)&&const DeepCollectionEquality().equals(other.daysOfWeek, daysOfWeek)&&(identical(other.date, date) || other.date == date)&&(identical(other.dailyGoal, dailyGoal) || other.dailyGoal == dailyGoal)&&(identical(other.goalUnit, goalUnit) || other.goalUnit == goalUnit)&&(identical(other.propId, propId) || other.propId == propId)&&(identical(other.doneLabel, doneLabel) || other.doneLabel == doneLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,category,emoji,messageTemplate,scheduleType,everyMinutes,activeFrom,activeTo,timeOfDay,const DeepCollectionEquality().hash(daysOfWeek),date,dailyGoal,goalUnit,propId,doneLabel);

@override
String toString() {
  return 'Starter(title: $title, category: $category, emoji: $emoji, messageTemplate: $messageTemplate, scheduleType: $scheduleType, everyMinutes: $everyMinutes, activeFrom: $activeFrom, activeTo: $activeTo, timeOfDay: $timeOfDay, daysOfWeek: $daysOfWeek, date: $date, dailyGoal: $dailyGoal, goalUnit: $goalUnit, propId: $propId, doneLabel: $doneLabel)';
}


}

/// @nodoc
abstract mixin class $StarterCopyWith<$Res>  {
  factory $StarterCopyWith(Starter value, $Res Function(Starter) _then) = _$StarterCopyWithImpl;
@useResult
$Res call({
 String title, String category, String emoji, String messageTemplate, ScheduleType scheduleType, int everyMinutes, String? activeFrom, String? activeTo, String timeOfDay, List<int> daysOfWeek, String? date, int dailyGoal, String goalUnit, String propId, String doneLabel
});




}
/// @nodoc
class _$StarterCopyWithImpl<$Res>
    implements $StarterCopyWith<$Res> {
  _$StarterCopyWithImpl(this._self, this._then);

  final Starter _self;
  final $Res Function(Starter) _then;

/// Create a copy of Starter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? category = null,Object? emoji = null,Object? messageTemplate = null,Object? scheduleType = null,Object? everyMinutes = null,Object? activeFrom = freezed,Object? activeTo = freezed,Object? timeOfDay = null,Object? daysOfWeek = null,Object? date = freezed,Object? dailyGoal = null,Object? goalUnit = null,Object? propId = null,Object? doneLabel = null,}) {
  return _then(Starter(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
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
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Starter].
extension StarterPatterns on Starter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Starter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Starter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Starter value)  $default,){
final _that = this;
switch (_that) {
case _Starter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Starter value)?  $default,){
final _that = this;
switch (_that) {
case _Starter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String category,  String emoji,  String messageTemplate,  ScheduleType scheduleType,  int everyMinutes,  String? activeFrom,  String? activeTo,  String timeOfDay,  List<int> daysOfWeek,  String? date,  int dailyGoal,  String goalUnit,  String propId,  String doneLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Starter() when $default != null:
return $default(_that.title,_that.category,_that.emoji,_that.messageTemplate,_that.scheduleType,_that.everyMinutes,_that.activeFrom,_that.activeTo,_that.timeOfDay,_that.daysOfWeek,_that.date,_that.dailyGoal,_that.goalUnit,_that.propId,_that.doneLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String category,  String emoji,  String messageTemplate,  ScheduleType scheduleType,  int everyMinutes,  String? activeFrom,  String? activeTo,  String timeOfDay,  List<int> daysOfWeek,  String? date,  int dailyGoal,  String goalUnit,  String propId,  String doneLabel)  $default,) {final _that = this;
switch (_that) {
case _Starter():
return $default(_that.title,_that.category,_that.emoji,_that.messageTemplate,_that.scheduleType,_that.everyMinutes,_that.activeFrom,_that.activeTo,_that.timeOfDay,_that.daysOfWeek,_that.date,_that.dailyGoal,_that.goalUnit,_that.propId,_that.doneLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String category,  String emoji,  String messageTemplate,  ScheduleType scheduleType,  int everyMinutes,  String? activeFrom,  String? activeTo,  String timeOfDay,  List<int> daysOfWeek,  String? date,  int dailyGoal,  String goalUnit,  String propId,  String doneLabel)?  $default,) {final _that = this;
switch (_that) {
case _Starter() when $default != null:
return $default(_that.title,_that.category,_that.emoji,_that.messageTemplate,_that.scheduleType,_that.everyMinutes,_that.activeFrom,_that.activeTo,_that.timeOfDay,_that.daysOfWeek,_that.date,_that.dailyGoal,_that.goalUnit,_that.propId,_that.doneLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Starter extends Starter {
  const _Starter({required this.title, required this.category, this.emoji = Strings.defaultReminderEmoji, this.messageTemplate = '', this.scheduleType = ScheduleType.interval, this.everyMinutes = 60, this.activeFrom, this.activeTo, this.timeOfDay = '09:00',  List<int> daysOfWeek = const <int>[], this.date, this.dailyGoal = 0, this.goalUnit = '', this.propId = defaultPropId, this.doneLabel = Strings.defaultDoneLabel}): _daysOfWeek = daysOfWeek,super._();
  factory _Starter.fromJson(Map<String, dynamic> json) => _$StarterFromJson(json);

@override final  String title;
/// Category *name*; resolved (or created) when the starter is used.
@override final  String category;
@override@JsonKey() final  String emoji;
@override@JsonKey() final  String messageTemplate;
@override@JsonKey() final  ScheduleType scheduleType;
@override@JsonKey() final  int everyMinutes;
@override final  String? activeFrom;
@override final  String? activeTo;
@override@JsonKey() final  String timeOfDay;
 final  List<int> _daysOfWeek;
@override@JsonKey() List<int> get daysOfWeek {
  if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daysOfWeek);
}

@override final  String? date;
@override@JsonKey() final  int dailyGoal;
@override@JsonKey() final  String goalUnit;
@override@JsonKey() final  String propId;
@override@JsonKey() final  String doneLabel;

/// Create a copy of Starter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StarterCopyWith<_Starter> get copyWith => __$StarterCopyWithImpl<_Starter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StarterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Starter&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.messageTemplate, messageTemplate) || other.messageTemplate == messageTemplate)&&(identical(other.scheduleType, scheduleType) || other.scheduleType == scheduleType)&&(identical(other.everyMinutes, everyMinutes) || other.everyMinutes == everyMinutes)&&(identical(other.activeFrom, activeFrom) || other.activeFrom == activeFrom)&&(identical(other.activeTo, activeTo) || other.activeTo == activeTo)&&(identical(other.timeOfDay, timeOfDay) || other.timeOfDay == timeOfDay)&&const DeepCollectionEquality().equals(other._daysOfWeek, _daysOfWeek)&&(identical(other.date, date) || other.date == date)&&(identical(other.dailyGoal, dailyGoal) || other.dailyGoal == dailyGoal)&&(identical(other.goalUnit, goalUnit) || other.goalUnit == goalUnit)&&(identical(other.propId, propId) || other.propId == propId)&&(identical(other.doneLabel, doneLabel) || other.doneLabel == doneLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,category,emoji,messageTemplate,scheduleType,everyMinutes,activeFrom,activeTo,timeOfDay,const DeepCollectionEquality().hash(_daysOfWeek),date,dailyGoal,goalUnit,propId,doneLabel);

@override
String toString() {
  return 'Starter(title: $title, category: $category, emoji: $emoji, messageTemplate: $messageTemplate, scheduleType: $scheduleType, everyMinutes: $everyMinutes, activeFrom: $activeFrom, activeTo: $activeTo, timeOfDay: $timeOfDay, daysOfWeek: $daysOfWeek, date: $date, dailyGoal: $dailyGoal, goalUnit: $goalUnit, propId: $propId, doneLabel: $doneLabel)';
}


}

/// @nodoc
abstract mixin class _$StarterCopyWith<$Res> implements $StarterCopyWith<$Res> {
  factory _$StarterCopyWith(_Starter value, $Res Function(_Starter) _then) = __$StarterCopyWithImpl;
@override @useResult
$Res call({
 String title, String category, String emoji, String messageTemplate, ScheduleType scheduleType, int everyMinutes, String? activeFrom, String? activeTo, String timeOfDay, List<int> daysOfWeek, String? date, int dailyGoal, String goalUnit, String propId, String doneLabel
});




}
/// @nodoc
class __$StarterCopyWithImpl<$Res>
    implements _$StarterCopyWith<$Res> {
  __$StarterCopyWithImpl(this._self, this._then);

  final _Starter _self;
  final $Res Function(_Starter) _then;

/// Create a copy of Starter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? category = null,Object? emoji = null,Object? messageTemplate = null,Object? scheduleType = null,Object? everyMinutes = null,Object? activeFrom = freezed,Object? activeTo = freezed,Object? timeOfDay = null,Object? daysOfWeek = null,Object? date = freezed,Object? dailyGoal = null,Object? goalUnit = null,Object? propId = null,Object? doneLabel = null,}) {
  return _then(_Starter(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
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
as String,
  ));
}


}

// dart format on
