import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// The bundled chime (`assets/sounds/chime.wav`). Pass [play] as the
/// scheduler's `PlayChime`.
class AudioplayersChime {
  AudioplayersChime() {
    // Short UI sound: don't hold or duck other apps' audio focus.
    unawaited(_player.setReleaseMode(ReleaseMode.stop));
  }

  final _player = AudioPlayer(playerId: 'desk_buddy_chime');

  Future<void> play() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/chime.wav'), volume: .9);
    } on Object {
      // No audio device etc. — a missing chime must never break a reminder.
    }
  }

  Future<void> dispose() => _player.dispose();
}
