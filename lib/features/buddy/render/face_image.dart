import 'dart:ui' as ui;

import 'package:flutter/services.dart';

const buddyFaceAsset = 'assets/character/face.png';

/// The photo face (D37), decoded once per engine.
abstract final class BuddyFaceImage {
  static Future<ui.Image>? _loading;

  static Future<ui.Image> load() => _loading ??= _load();

  static Future<ui.Image> _load() async {
    final data = await rootBundle.load(buddyFaceAsset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    return (await codec.getNextFrame()).image;
  }
}
