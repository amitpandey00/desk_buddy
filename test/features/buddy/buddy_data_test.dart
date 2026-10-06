import 'package:desk_buddy/features/buddy/domain/buddy_look.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BuddyLook JSON round-trip keeps enums and defaults', () {
    const look = LookPresets.cozy;
    final json = look.toJson();
    expect(json['hairStyle'], 'none');
    expect(json['hat'], 'beanie');
    expect(BuddyLook.fromJson(json), look);
    final minimal = BuddyLook.fromJson({
      'skinHex': '#000000',
      'hairHex': '#000000',
      'jacketHex': '#000000',
      'shirtHex': '#000000',
      'pantsHex': '#000000',
      'shoesHex': '#000000',
    });
    expect(minimal.defaultPropId, 'none');
    expect(minimal.hairStyle, HairStyle.spiky);
  });
}
