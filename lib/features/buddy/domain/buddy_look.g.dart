// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buddy_look.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BuddyLook _$BuddyLookFromJson(Map<String, dynamic> json) => _BuddyLook(
  skinHex: json['skinHex'] as String,
  hairHex: json['hairHex'] as String,
  jacketHex: json['jacketHex'] as String,
  shirtHex: json['shirtHex'] as String,
  pantsHex: json['pantsHex'] as String,
  shoesHex: json['shoesHex'] as String,
  hairStyle:
      $enumDecodeNullable(_$HairStyleEnumMap, json['hairStyle']) ??
      HairStyle.spiky,
  hat: $enumDecodeNullable(_$HatStyleEnumMap, json['hat']) ?? HatStyle.none,
  spectacles: json['spectacles'] as bool? ?? false,
  defaultPropId: json['defaultPropId'] as String? ?? 'none',
);

Map<String, dynamic> _$BuddyLookToJson(_BuddyLook instance) =>
    <String, dynamic>{
      'skinHex': instance.skinHex,
      'hairHex': instance.hairHex,
      'jacketHex': instance.jacketHex,
      'shirtHex': instance.shirtHex,
      'pantsHex': instance.pantsHex,
      'shoesHex': instance.shoesHex,
      'hairStyle': _$HairStyleEnumMap[instance.hairStyle]!,
      'hat': _$HatStyleEnumMap[instance.hat]!,
      'spectacles': instance.spectacles,
      'defaultPropId': instance.defaultPropId,
    };

const _$HairStyleEnumMap = {
  HairStyle.spiky: 'spiky',
  HairStyle.short: 'short',
  HairStyle.long: 'long',
  HairStyle.none: 'none',
};

const _$HatStyleEnumMap = {
  HatStyle.none: 'none',
  HatStyle.cap: 'cap',
  HatStyle.beanie: 'beanie',
};
