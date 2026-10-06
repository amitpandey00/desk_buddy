import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the bundled fonts so goldens show real text instead of Ahem boxes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File('assets/fonts/$f').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await load('Baloo2', ['Baloo2-500.ttf', 'Baloo2-700.ttf', 'Baloo2-800.ttf']);
  await load('Figtree', [
    'Figtree-400.ttf',
    'Figtree-500.ttf',
    'Figtree-600.ttf',
    'Figtree-700.ttf',
  ]);
  await testMain();
}
