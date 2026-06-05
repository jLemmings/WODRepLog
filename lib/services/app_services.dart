import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/recorder_settings.dart';
import '../domain/workout_timer.dart';

class CameraService {
  const CameraService();

  Future<List<CameraDescription>> availableDeviceCameras() {
    return availableCameras();
  }
}

class NativeBeepService {
  const NativeBeepService({
    this.channel = const MethodChannel('ch.joshuahemmings.wodreplog/beep'),
  });

  final MethodChannel channel;

  Future<void> play(Duration duration) async {
    try {
      await channel.invokeMethod<void>('playBeep', {
        'durationMs': duration.inMilliseconds,
      });
    } on MissingPluginException {
      // Audio cues are non-critical.
    } on PlatformException {
      // Audio cues are non-critical.
    }
  }

  Future<void> stop() async {
    try {
      await channel.invokeMethod<void>('stopBeep');
    } on MissingPluginException {
      // Audio cues are non-critical.
    } on PlatformException {
      // Audio cues are non-critical.
    }
  }
}

class AppInfoService {
  const AppInfoService({
    this.channel = const MethodChannel('ch.joshuahemmings.wodreplog/app_info'),
  });

  final MethodChannel channel;

  Future<String?> versionName() async {
    try {
      return channel.invokeMethod<String>('getVersionName');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

class VideoOverlayRequest {
  const VideoOverlayRequest({
    required this.inputPath,
    required this.outputPath,
    required this.athleteName,
    required this.eventName,
    required this.workoutTitle,
    required this.countdownSeconds,
    required this.labels,
    required this.eventLabel,
    required this.athleteLabel,
    required this.workoutLabel,
    this.timerConfiguration,
  });

  final String inputPath;
  final String outputPath;
  final String athleteName;
  final String eventName;
  final String workoutTitle;
  final int countdownSeconds;
  final TimerOverlayLabels labels;
  final String eventLabel;
  final String athleteLabel;
  final String workoutLabel;
  final TimerConfiguration? timerConfiguration;

  Map<String, Object?> toChannelArguments() {
    return {
      'inputPath': inputPath,
      'outputPath': outputPath,
      'athleteName': athleteName,
      'eventName': eventName,
      'workoutTitle': workoutTitle,
      'timerType': timerConfiguration?.type.name,
      'timerIntervalSeconds': timerConfiguration?.intervalSeconds,
      'timerRounds': timerConfiguration?.rounds,
      'timerTotalSeconds': timerConfiguration?.totalSeconds,
      'countdownSeconds': countdownSeconds,
      'eventLabel': eventLabel,
      'athleteLabel': athleteLabel,
      'workoutLabel': workoutLabel,
      'roundLabel': labels.round,
      'countdownLabel': labels.countdown,
      'startsInLabel': labels.startsIn,
      'nextStartLabel': labels.nextStart,
      'elapsedLabel': labels.elapsed,
      'remainingLabel': labels.remaining,
      'remainingSuffix': labels.remainingSuffix,
      'elapsedSuffix': labels.elapsedSuffix,
    };
  }
}

class VideoOverlayService {
  const VideoOverlayService({
    this.channel = const MethodChannel(
      'ch.joshuahemmings.wodreplog/video_overlay',
    ),
  });

  final MethodChannel channel;

  Future<String> embedOverlay(VideoOverlayRequest request) async {
    try {
      final result = await channel.invokeMethod<String>(
        'embedOverlay',
        request.toChannelArguments(),
      );
      return result ?? request.outputPath;
    } on MissingPluginException {
      return request.inputPath;
    }
  }

  String proofOutputPath(String inputPath) {
    return '${path.withoutExtension(inputPath)}_proof.mp4';
  }
}

class GalleryService {
  const GalleryService();

  Future<void> saveVideo(String path) {
    return Gal.putVideo(path);
  }
}

class HomePreferencesStore {
  const HomePreferencesStore(this._preferences);

  static const athleteNameKey = 'athleteName';
  static const languageCodeKey = 'languageCode';

  final SharedPreferences _preferences;

  String get athleteName => _preferences.getString(athleteNameKey) ?? '';
  String? get languageCode => _preferences.getString(languageCodeKey);

  Future<void> save({
    required String athleteName,
    required String languageCode,
  }) async {
    await _preferences.setString(athleteNameKey, athleteName);
    await _preferences.setString(languageCodeKey, languageCode);
  }
}

class RecorderSettingsStore {
  const RecorderSettingsStore(this._preferences);

  static const _athleteNameKey = 'recorderAthleteName';
  static const _eventNameKey = 'recorderEventName';
  static const _workoutTitleKey = 'recorderWorkoutTitle';
  static const _countdownSecondsKey = 'recorderCountdownSeconds';
  static const _timerTypeKey = 'recorderTimerType';
  static const _timerIntervalSecondsKey = 'recorderTimerIntervalSeconds';
  static const _timerRoundsKey = 'recorderTimerRounds';
  static const _timerTotalSecondsKey = 'recorderTimerTotalSeconds';

  final SharedPreferences _preferences;

  RecorderSettings load({required String fallbackAthleteName}) {
    return RecorderSettings(
      athleteName:
          _preferences.getString(_athleteNameKey) ?? fallbackAthleteName,
      eventName: _preferences.getString(_eventNameKey) ?? '',
      workoutTitle: _preferences.getString(_workoutTitleKey) ?? '',
      countdownSeconds: _preferences.getInt(_countdownSecondsKey) ?? 10,
      timerConfiguration: _storedTimerConfiguration(),
    );
  }

  TimerConfiguration? _storedTimerConfiguration() {
    final timerTypeName = _preferences.getString(_timerTypeKey);
    final timerType = WorkoutTimerType.values
        .where((type) => type.name == timerTypeName)
        .firstOrNull;
    if (timerType == null) return null;

    switch (timerType) {
      case WorkoutTimerType.emom:
        return TimerConfiguration(
          type: timerType,
          intervalSeconds: _preferences.getInt(_timerIntervalSecondsKey),
          rounds: _preferences.getInt(_timerRoundsKey),
        );
      case WorkoutTimerType.amrap:
      case WorkoutTimerType.forTime:
      case WorkoutTimerType.tabata:
        return TimerConfiguration(
          type: timerType,
          totalSeconds: _preferences.getInt(_timerTotalSecondsKey),
        );
    }
  }

  Future<void> save(RecorderSettings settings) async {
    await _preferences.setString(_athleteNameKey, settings.athleteName);
    await _preferences.setString(_eventNameKey, settings.eventName);
    await _preferences.setString(_workoutTitleKey, settings.workoutTitle);
    await _preferences.setInt(_countdownSecondsKey, settings.countdownSeconds);

    final timerConfig = settings.timerConfiguration;
    if (timerConfig == null) {
      await _preferences.remove(_timerTypeKey);
      await _preferences.remove(_timerIntervalSecondsKey);
      await _preferences.remove(_timerRoundsKey);
      await _preferences.remove(_timerTotalSecondsKey);
      return;
    }

    await _preferences.setString(_timerTypeKey, timerConfig.type.name);
    switch (timerConfig.type) {
      case WorkoutTimerType.emom:
        await _preferences.setInt(
          _timerIntervalSecondsKey,
          timerConfig.intervalSeconds ?? 60,
        );
        await _preferences.setInt(_timerRoundsKey, timerConfig.rounds ?? 10);
        await _preferences.remove(_timerTotalSecondsKey);
        break;
      case WorkoutTimerType.amrap:
      case WorkoutTimerType.forTime:
      case WorkoutTimerType.tabata:
        await _preferences.setInt(
          _timerTotalSecondsKey,
          timerConfig.totalSeconds ?? 0,
        );
        await _preferences.remove(_timerIntervalSecondsKey);
        await _preferences.remove(_timerRoundsKey);
        break;
    }
  }
}
