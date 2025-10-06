import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Manages all short lived sound effects used by the timers.
///
/// Keeping the audio handling in a dedicated class avoids scattering the
/// resource management logic across multiple widgets.
class SoundService {
  SoundService()
      : _countdownPlayer = AudioPlayer(),
        _signalPlayer = AudioPlayer();

  final AudioPlayer _countdownPlayer;
  final AudioPlayer _signalPlayer;

  Future<void> playCountdownBeep() => _play(_countdownPlayer, 'beep.wav');

  Future<void> playStartBeep() => _play(_signalPlayer, 'start_beep.wav');

  Future<void> playRestBeep() => _play(_signalPlayer, 'beep.wav', volume: 0.6);

  Future<void> _play(AudioPlayer player, String asset, {double volume = 1.0}) async {
    try {
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(volume);
      await player.play(AssetSource(asset));
    } catch (error) {
      debugPrint('Failed to play $asset: $error');
    }
  }

  Future<void> dispose() async {
    await _countdownPlayer.dispose();
    await _signalPlayer.dispose();
  }
}
