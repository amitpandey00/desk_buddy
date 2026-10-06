import 'package:freezed_annotation/freezed_annotation.dart';

part 'buddy_look.freezed.dart';
part 'buddy_look.g.dart';

enum HairStyle { spiky, short, long, none }

enum HatStyle { none, cap, beanie }

/// How the buddy looks. Colors are `#RRGGBB`. `defaultPropId` is a key of
/// the prop registry: what the buddy holds when a reminder doesn't say.
@freezed
abstract class BuddyLook with _$BuddyLook {
  const factory BuddyLook({
    required String skinHex,
    required String hairHex,
    required String jacketHex,
    required String shirtHex,
    required String pantsHex,
    required String shoesHex,
    @Default(HairStyle.spiky) HairStyle hairStyle,
    @Default(HatStyle.none) HatStyle hat,
    @Default(false) bool spectacles,
    @Default('none') String defaultPropId,
  }) = _BuddyLook;

  factory BuddyLook.fromJson(Map<String, dynamic> json) =>
      _$BuddyLookFromJson(json);
}

/// The Character screen's starting points (prototype `LOOKS`).
abstract final class LookPresets {
  static const classic = BuddyLook(
    skinHex: '#E9B48A',
    hairHex: '#2B1B12',
    jacketHex: '#4E7FB8',
    shirtHex: '#5B6470',
    pantsHex: '#3A3F47',
    shoesHex: '#F4F4F4',
  );
  static const sporty = BuddyLook(
    skinHex: '#C68A5E',
    hairHex: '#111111',
    jacketHex: '#E8473A',
    shirtHex: '#FFFFFF',
    pantsHex: '#1E2A3A',
    shoesHex: '#FFCB2E',
    hairStyle: HairStyle.short,
    hat: HatStyle.cap,
  );
  static const office = BuddyLook(
    skinHex: '#F1C9A5',
    hairHex: '#5A3A22',
    jacketHex: '#2F3E50',
    shirtHex: '#DCE8F2',
    pantsHex: '#2B2F36',
    shoesHex: '#3B2A20',
    hairStyle: HairStyle.long,
    spectacles: true,
    defaultPropId: 'coffee',
  );
  static const cozy = BuddyLook(
    skinHex: '#8D5B3E',
    hairHex: '#1A1A1A',
    jacketHex: '#1FA97F',
    shirtHex: '#F3E7C9',
    pantsHex: '#4B3B2F',
    shoesHex: '#E9E2D0',
    hairStyle: HairStyle.none,
    hat: HatStyle.beanie,
    spectacles: true,
    defaultPropId: 'book',
  );

  static const Map<String, BuddyLook> all = {
    'classic': classic,
    'sporty': sporty,
    'office': office,
    'cozy': cozy,
  };
}
