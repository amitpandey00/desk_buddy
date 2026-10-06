// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'buddy_look.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BuddyLook {

 String get skinHex; String get hairHex; String get jacketHex; String get shirtHex; String get pantsHex; String get shoesHex; HairStyle get hairStyle; HatStyle get hat; bool get spectacles; String get defaultPropId;
/// Create a copy of BuddyLook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuddyLookCopyWith<BuddyLook> get copyWith => _$BuddyLookCopyWithImpl<BuddyLook>(this as BuddyLook, _$identity);

  /// Serializes this BuddyLook to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuddyLook&&(identical(other.skinHex, skinHex) || other.skinHex == skinHex)&&(identical(other.hairHex, hairHex) || other.hairHex == hairHex)&&(identical(other.jacketHex, jacketHex) || other.jacketHex == jacketHex)&&(identical(other.shirtHex, shirtHex) || other.shirtHex == shirtHex)&&(identical(other.pantsHex, pantsHex) || other.pantsHex == pantsHex)&&(identical(other.shoesHex, shoesHex) || other.shoesHex == shoesHex)&&(identical(other.hairStyle, hairStyle) || other.hairStyle == hairStyle)&&(identical(other.hat, hat) || other.hat == hat)&&(identical(other.spectacles, spectacles) || other.spectacles == spectacles)&&(identical(other.defaultPropId, defaultPropId) || other.defaultPropId == defaultPropId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,skinHex,hairHex,jacketHex,shirtHex,pantsHex,shoesHex,hairStyle,hat,spectacles,defaultPropId);

@override
String toString() {
  return 'BuddyLook(skinHex: $skinHex, hairHex: $hairHex, jacketHex: $jacketHex, shirtHex: $shirtHex, pantsHex: $pantsHex, shoesHex: $shoesHex, hairStyle: $hairStyle, hat: $hat, spectacles: $spectacles, defaultPropId: $defaultPropId)';
}


}

/// @nodoc
abstract mixin class $BuddyLookCopyWith<$Res>  {
  factory $BuddyLookCopyWith(BuddyLook value, $Res Function(BuddyLook) _then) = _$BuddyLookCopyWithImpl;
@useResult
$Res call({
 String skinHex, String hairHex, String jacketHex, String shirtHex, String pantsHex, String shoesHex, HairStyle hairStyle, HatStyle hat, bool spectacles, String defaultPropId
});




}
/// @nodoc
class _$BuddyLookCopyWithImpl<$Res>
    implements $BuddyLookCopyWith<$Res> {
  _$BuddyLookCopyWithImpl(this._self, this._then);

  final BuddyLook _self;
  final $Res Function(BuddyLook) _then;

/// Create a copy of BuddyLook
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? skinHex = null,Object? hairHex = null,Object? jacketHex = null,Object? shirtHex = null,Object? pantsHex = null,Object? shoesHex = null,Object? hairStyle = null,Object? hat = null,Object? spectacles = null,Object? defaultPropId = null,}) {
  return _then(BuddyLook(
skinHex: null == skinHex ? _self.skinHex : skinHex // ignore: cast_nullable_to_non_nullable
as String,hairHex: null == hairHex ? _self.hairHex : hairHex // ignore: cast_nullable_to_non_nullable
as String,jacketHex: null == jacketHex ? _self.jacketHex : jacketHex // ignore: cast_nullable_to_non_nullable
as String,shirtHex: null == shirtHex ? _self.shirtHex : shirtHex // ignore: cast_nullable_to_non_nullable
as String,pantsHex: null == pantsHex ? _self.pantsHex : pantsHex // ignore: cast_nullable_to_non_nullable
as String,shoesHex: null == shoesHex ? _self.shoesHex : shoesHex // ignore: cast_nullable_to_non_nullable
as String,hairStyle: null == hairStyle ? _self.hairStyle : hairStyle // ignore: cast_nullable_to_non_nullable
as HairStyle,hat: null == hat ? _self.hat : hat // ignore: cast_nullable_to_non_nullable
as HatStyle,spectacles: null == spectacles ? _self.spectacles : spectacles // ignore: cast_nullable_to_non_nullable
as bool,defaultPropId: null == defaultPropId ? _self.defaultPropId : defaultPropId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BuddyLook].
extension BuddyLookPatterns on BuddyLook {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuddyLook value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuddyLook() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuddyLook value)  $default,){
final _that = this;
switch (_that) {
case _BuddyLook():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuddyLook value)?  $default,){
final _that = this;
switch (_that) {
case _BuddyLook() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String skinHex,  String hairHex,  String jacketHex,  String shirtHex,  String pantsHex,  String shoesHex,  HairStyle hairStyle,  HatStyle hat,  bool spectacles,  String defaultPropId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuddyLook() when $default != null:
return $default(_that.skinHex,_that.hairHex,_that.jacketHex,_that.shirtHex,_that.pantsHex,_that.shoesHex,_that.hairStyle,_that.hat,_that.spectacles,_that.defaultPropId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String skinHex,  String hairHex,  String jacketHex,  String shirtHex,  String pantsHex,  String shoesHex,  HairStyle hairStyle,  HatStyle hat,  bool spectacles,  String defaultPropId)  $default,) {final _that = this;
switch (_that) {
case _BuddyLook():
return $default(_that.skinHex,_that.hairHex,_that.jacketHex,_that.shirtHex,_that.pantsHex,_that.shoesHex,_that.hairStyle,_that.hat,_that.spectacles,_that.defaultPropId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String skinHex,  String hairHex,  String jacketHex,  String shirtHex,  String pantsHex,  String shoesHex,  HairStyle hairStyle,  HatStyle hat,  bool spectacles,  String defaultPropId)?  $default,) {final _that = this;
switch (_that) {
case _BuddyLook() when $default != null:
return $default(_that.skinHex,_that.hairHex,_that.jacketHex,_that.shirtHex,_that.pantsHex,_that.shoesHex,_that.hairStyle,_that.hat,_that.spectacles,_that.defaultPropId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuddyLook implements BuddyLook {
  const _BuddyLook({required this.skinHex, required this.hairHex, required this.jacketHex, required this.shirtHex, required this.pantsHex, required this.shoesHex, this.hairStyle = HairStyle.spiky, this.hat = HatStyle.none, this.spectacles = false, this.defaultPropId = 'none'});
  factory _BuddyLook.fromJson(Map<String, dynamic> json) => _$BuddyLookFromJson(json);

@override final  String skinHex;
@override final  String hairHex;
@override final  String jacketHex;
@override final  String shirtHex;
@override final  String pantsHex;
@override final  String shoesHex;
@override@JsonKey() final  HairStyle hairStyle;
@override@JsonKey() final  HatStyle hat;
@override@JsonKey() final  bool spectacles;
@override@JsonKey() final  String defaultPropId;

/// Create a copy of BuddyLook
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuddyLookCopyWith<_BuddyLook> get copyWith => __$BuddyLookCopyWithImpl<_BuddyLook>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuddyLookToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuddyLook&&(identical(other.skinHex, skinHex) || other.skinHex == skinHex)&&(identical(other.hairHex, hairHex) || other.hairHex == hairHex)&&(identical(other.jacketHex, jacketHex) || other.jacketHex == jacketHex)&&(identical(other.shirtHex, shirtHex) || other.shirtHex == shirtHex)&&(identical(other.pantsHex, pantsHex) || other.pantsHex == pantsHex)&&(identical(other.shoesHex, shoesHex) || other.shoesHex == shoesHex)&&(identical(other.hairStyle, hairStyle) || other.hairStyle == hairStyle)&&(identical(other.hat, hat) || other.hat == hat)&&(identical(other.spectacles, spectacles) || other.spectacles == spectacles)&&(identical(other.defaultPropId, defaultPropId) || other.defaultPropId == defaultPropId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,skinHex,hairHex,jacketHex,shirtHex,pantsHex,shoesHex,hairStyle,hat,spectacles,defaultPropId);

@override
String toString() {
  return 'BuddyLook(skinHex: $skinHex, hairHex: $hairHex, jacketHex: $jacketHex, shirtHex: $shirtHex, pantsHex: $pantsHex, shoesHex: $shoesHex, hairStyle: $hairStyle, hat: $hat, spectacles: $spectacles, defaultPropId: $defaultPropId)';
}


}

/// @nodoc
abstract mixin class _$BuddyLookCopyWith<$Res> implements $BuddyLookCopyWith<$Res> {
  factory _$BuddyLookCopyWith(_BuddyLook value, $Res Function(_BuddyLook) _then) = __$BuddyLookCopyWithImpl;
@override @useResult
$Res call({
 String skinHex, String hairHex, String jacketHex, String shirtHex, String pantsHex, String shoesHex, HairStyle hairStyle, HatStyle hat, bool spectacles, String defaultPropId
});




}
/// @nodoc
class __$BuddyLookCopyWithImpl<$Res>
    implements _$BuddyLookCopyWith<$Res> {
  __$BuddyLookCopyWithImpl(this._self, this._then);

  final _BuddyLook _self;
  final $Res Function(_BuddyLook) _then;

/// Create a copy of BuddyLook
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? skinHex = null,Object? hairHex = null,Object? jacketHex = null,Object? shirtHex = null,Object? pantsHex = null,Object? shoesHex = null,Object? hairStyle = null,Object? hat = null,Object? spectacles = null,Object? defaultPropId = null,}) {
  return _then(_BuddyLook(
skinHex: null == skinHex ? _self.skinHex : skinHex // ignore: cast_nullable_to_non_nullable
as String,hairHex: null == hairHex ? _self.hairHex : hairHex // ignore: cast_nullable_to_non_nullable
as String,jacketHex: null == jacketHex ? _self.jacketHex : jacketHex // ignore: cast_nullable_to_non_nullable
as String,shirtHex: null == shirtHex ? _self.shirtHex : shirtHex // ignore: cast_nullable_to_non_nullable
as String,pantsHex: null == pantsHex ? _self.pantsHex : pantsHex // ignore: cast_nullable_to_non_nullable
as String,shoesHex: null == shoesHex ? _self.shoesHex : shoesHex // ignore: cast_nullable_to_non_nullable
as String,hairStyle: null == hairStyle ? _self.hairStyle : hairStyle // ignore: cast_nullable_to_non_nullable
as HairStyle,hat: null == hat ? _self.hat : hat // ignore: cast_nullable_to_non_nullable
as HatStyle,spectacles: null == spectacles ? _self.spectacles : spectacles // ignore: cast_nullable_to_non_nullable
as bool,defaultPropId: null == defaultPropId ? _self.defaultPropId : defaultPropId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
