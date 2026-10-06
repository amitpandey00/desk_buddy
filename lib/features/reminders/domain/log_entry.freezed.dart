// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'log_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LogEntry {

 String get id;/// Epoch ms.
 int get at; LogAction get action; String? get reminderId;/// Snapshot of the reminder's category when this was logged.
 String? get categoryId;/// From pop-up to response.
 int get responseSeconds;/// Logged with "+1" rather than answering a pop-up.
 bool get manual;/// Generated history (debug builds only), removable in one go.
 bool get sample;
/// Create a copy of LogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogEntryCopyWith<LogEntry> get copyWith => _$LogEntryCopyWithImpl<LogEntry>(this as LogEntry, _$identity);

  /// Serializes this LogEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.at, at) || other.at == at)&&(identical(other.action, action) || other.action == action)&&(identical(other.reminderId, reminderId) || other.reminderId == reminderId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.responseSeconds, responseSeconds) || other.responseSeconds == responseSeconds)&&(identical(other.manual, manual) || other.manual == manual)&&(identical(other.sample, sample) || other.sample == sample));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,at,action,reminderId,categoryId,responseSeconds,manual,sample);

@override
String toString() {
  return 'LogEntry(id: $id, at: $at, action: $action, reminderId: $reminderId, categoryId: $categoryId, responseSeconds: $responseSeconds, manual: $manual, sample: $sample)';
}


}

/// @nodoc
abstract mixin class $LogEntryCopyWith<$Res>  {
  factory $LogEntryCopyWith(LogEntry value, $Res Function(LogEntry) _then) = _$LogEntryCopyWithImpl;
@useResult
$Res call({
 String id, int at, LogAction action, String? reminderId, String? categoryId, int responseSeconds, bool manual, bool sample
});




}
/// @nodoc
class _$LogEntryCopyWithImpl<$Res>
    implements $LogEntryCopyWith<$Res> {
  _$LogEntryCopyWithImpl(this._self, this._then);

  final LogEntry _self;
  final $Res Function(LogEntry) _then;

/// Create a copy of LogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? at = null,Object? action = null,Object? reminderId = freezed,Object? categoryId = freezed,Object? responseSeconds = null,Object? manual = null,Object? sample = null,}) {
  return _then(LogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as int,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as LogAction,reminderId: freezed == reminderId ? _self.reminderId : reminderId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,responseSeconds: null == responseSeconds ? _self.responseSeconds : responseSeconds // ignore: cast_nullable_to_non_nullable
as int,manual: null == manual ? _self.manual : manual // ignore: cast_nullable_to_non_nullable
as bool,sample: null == sample ? _self.sample : sample // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LogEntry].
extension LogEntryPatterns on LogEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogEntry value)  $default,){
final _that = this;
switch (_that) {
case _LogEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LogEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int at,  LogAction action,  String? reminderId,  String? categoryId,  int responseSeconds,  bool manual,  bool sample)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogEntry() when $default != null:
return $default(_that.id,_that.at,_that.action,_that.reminderId,_that.categoryId,_that.responseSeconds,_that.manual,_that.sample);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int at,  LogAction action,  String? reminderId,  String? categoryId,  int responseSeconds,  bool manual,  bool sample)  $default,) {final _that = this;
switch (_that) {
case _LogEntry():
return $default(_that.id,_that.at,_that.action,_that.reminderId,_that.categoryId,_that.responseSeconds,_that.manual,_that.sample);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int at,  LogAction action,  String? reminderId,  String? categoryId,  int responseSeconds,  bool manual,  bool sample)?  $default,) {final _that = this;
switch (_that) {
case _LogEntry() when $default != null:
return $default(_that.id,_that.at,_that.action,_that.reminderId,_that.categoryId,_that.responseSeconds,_that.manual,_that.sample);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LogEntry implements LogEntry {
  const _LogEntry({required this.id, required this.at, required this.action, this.reminderId, this.categoryId, this.responseSeconds = 0, this.manual = false, this.sample = false});
  factory _LogEntry.fromJson(Map<String, dynamic> json) => _$LogEntryFromJson(json);

@override final  String id;
/// Epoch ms.
@override final  int at;
@override final  LogAction action;
@override final  String? reminderId;
/// Snapshot of the reminder's category when this was logged.
@override final  String? categoryId;
/// From pop-up to response.
@override@JsonKey() final  int responseSeconds;
/// Logged with "+1" rather than answering a pop-up.
@override@JsonKey() final  bool manual;
/// Generated history (debug builds only), removable in one go.
@override@JsonKey() final  bool sample;

/// Create a copy of LogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogEntryCopyWith<_LogEntry> get copyWith => __$LogEntryCopyWithImpl<_LogEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LogEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.at, at) || other.at == at)&&(identical(other.action, action) || other.action == action)&&(identical(other.reminderId, reminderId) || other.reminderId == reminderId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.responseSeconds, responseSeconds) || other.responseSeconds == responseSeconds)&&(identical(other.manual, manual) || other.manual == manual)&&(identical(other.sample, sample) || other.sample == sample));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,at,action,reminderId,categoryId,responseSeconds,manual,sample);

@override
String toString() {
  return 'LogEntry(id: $id, at: $at, action: $action, reminderId: $reminderId, categoryId: $categoryId, responseSeconds: $responseSeconds, manual: $manual, sample: $sample)';
}


}

/// @nodoc
abstract mixin class _$LogEntryCopyWith<$Res> implements $LogEntryCopyWith<$Res> {
  factory _$LogEntryCopyWith(_LogEntry value, $Res Function(_LogEntry) _then) = __$LogEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, int at, LogAction action, String? reminderId, String? categoryId, int responseSeconds, bool manual, bool sample
});




}
/// @nodoc
class __$LogEntryCopyWithImpl<$Res>
    implements _$LogEntryCopyWith<$Res> {
  __$LogEntryCopyWithImpl(this._self, this._then);

  final _LogEntry _self;
  final $Res Function(_LogEntry) _then;

/// Create a copy of LogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? at = null,Object? action = null,Object? reminderId = freezed,Object? categoryId = freezed,Object? responseSeconds = null,Object? manual = null,Object? sample = null,}) {
  return _then(_LogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as int,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as LogAction,reminderId: freezed == reminderId ? _self.reminderId : reminderId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,responseSeconds: null == responseSeconds ? _self.responseSeconds : responseSeconds // ignore: cast_nullable_to_non_nullable
as int,manual: null == manual ? _self.manual : manual // ignore: cast_nullable_to_non_nullable
as bool,sample: null == sample ? _self.sample : sample // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
