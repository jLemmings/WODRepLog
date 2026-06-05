import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';

enum WorkoutTimerType { emom, amrap, forTime }

class TimerConfiguration {
  const TimerConfiguration({
    required this.type,
    this.intervalSeconds,
    this.rounds,
    this.totalSeconds,
  });

  final WorkoutTimerType type;
  final int? intervalSeconds;
  final int? rounds;
  final int? totalSeconds;
}

class RecorderSettings {
  const RecorderSettings({
    required this.athleteName,
    required this.eventName,
    required this.workoutTitle,
    required this.countdownSeconds,
    this.timerConfiguration,
  });

  final String athleteName;
  final String eventName;
  final String workoutTitle;
  final int countdownSeconds;
  final TimerConfiguration? timerConfiguration;
}

class VideoRecorder extends StatefulWidget {
  const VideoRecorder({super.key, this.initialAthleteName = ''});

  final String initialAthleteName;

  @override
  VideoRecorderState createState() => VideoRecorderState();
}

class VideoRecorderState extends State<VideoRecorder> {
  static const String _athleteNamePreferenceKey = 'recorderAthleteName';
  static const String _eventNamePreferenceKey = 'recorderEventName';
  static const String _workoutTitlePreferenceKey = 'recorderWorkoutTitle';
  static const String _countdownSecondsPreferenceKey =
      'recorderCountdownSeconds';
  static const String _timerTypePreferenceKey = 'recorderTimerType';
  static const String _timerIntervalSecondsPreferenceKey =
      'recorderTimerIntervalSeconds';
  static const String _timerRoundsPreferenceKey = 'recorderTimerRounds';
  static const String _timerTotalSecondsPreferenceKey =
      'recorderTimerTotalSeconds';
  static const MethodChannel _videoOverlayChannel = MethodChannel(
    'ch.joshuahemmings.wodreplog/video_overlay',
  );
  static const MethodChannel _beepChannel = MethodChannel(
    'ch.joshuahemmings.wodreplog/beep',
  );
  static const Duration _countdownBeepDuration = Duration(milliseconds: 180);
  static const Duration _startBeepDuration = Duration(seconds: 2);

  late CameraController _controller;
  bool _isRecording = false;
  bool _isProcessingVideo = false;
  bool _isCountingDown = false;
  Timer? _ticker;
  Timer? _countdownTicker;
  Duration _elapsed = Duration.zero;
  int _countdownSeconds = 10;
  int _countdownRemaining = 0;

  String _athleteName = '';
  String _eventName = '';
  String _workoutTitle = '';
  TimerConfiguration? _timerConfig;
  @override
  void initState() {
    super.initState();
    _athleteName = widget.initialAthleteName.trim();
    unawaited(_loadStoredSettings());
    _initializeCamera();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void didUpdateWidget(covariant VideoRecorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previousInitialAthleteName = oldWidget.initialAthleteName.trim();
    final nextInitialAthleteName = widget.initialAthleteName.trim();
    if (_athleteName == previousInitialAthleteName &&
        nextInitialAthleteName != previousInitialAthleteName) {
      _athleteName = nextInitialAthleteName;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _countdownTicker?.cancel();
    unawaited(_stopNativeBeep());
    _controller.dispose();

    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;
      _controller = CameraController(camera, ResolutionPreset.high);
      await _controller.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(
        AppLocalizations.of(context).failedInitializeCamera(e.toString()),
      );
    }
  }

  Future<void> _loadStoredSettings() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;

    final storedAthleteName = preferences.getString(_athleteNamePreferenceKey);
    final storedEventName = preferences.getString(_eventNamePreferenceKey);
    final storedWorkoutTitle = preferences.getString(
      _workoutTitlePreferenceKey,
    );
    final storedCountdownSeconds = preferences.getInt(
      _countdownSecondsPreferenceKey,
    );
    final storedTimerConfiguration = _storedTimerConfiguration(preferences);

    setState(() {
      if (storedAthleteName != null) {
        _athleteName = storedAthleteName;
      }
      if (storedEventName != null) {
        _eventName = storedEventName;
      }
      if (storedWorkoutTitle != null) {
        _workoutTitle = storedWorkoutTitle;
      }
      if (storedCountdownSeconds != null) {
        _countdownSeconds = storedCountdownSeconds;
      }
      _timerConfig = storedTimerConfiguration;
    });
  }

  TimerConfiguration? _storedTimerConfiguration(SharedPreferences preferences) {
    final timerTypeName = preferences.getString(_timerTypePreferenceKey);
    final timerType = WorkoutTimerType.values
        .where((type) => type.name == timerTypeName)
        .firstOrNull;
    if (timerType == null) return null;

    switch (timerType) {
      case WorkoutTimerType.emom:
        return TimerConfiguration(
          type: timerType,
          intervalSeconds: preferences.getInt(
            _timerIntervalSecondsPreferenceKey,
          ),
          rounds: preferences.getInt(_timerRoundsPreferenceKey),
        );
      case WorkoutTimerType.amrap:
      case WorkoutTimerType.forTime:
        return TimerConfiguration(
          type: timerType,
          totalSeconds: preferences.getInt(_timerTotalSecondsPreferenceKey),
        );
    }
  }

  Future<void> _storeSettings() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_athleteNamePreferenceKey, _athleteName);
    await preferences.setString(_eventNamePreferenceKey, _eventName);
    await preferences.setString(_workoutTitlePreferenceKey, _workoutTitle);
    await preferences.setInt(_countdownSecondsPreferenceKey, _countdownSeconds);

    final timerConfig = _timerConfig;
    if (timerConfig == null) {
      await preferences.remove(_timerTypePreferenceKey);
      await preferences.remove(_timerIntervalSecondsPreferenceKey);
      await preferences.remove(_timerRoundsPreferenceKey);
      await preferences.remove(_timerTotalSecondsPreferenceKey);
      return;
    }

    await preferences.setString(_timerTypePreferenceKey, timerConfig.type.name);
    switch (timerConfig.type) {
      case WorkoutTimerType.emom:
        await preferences.setInt(
          _timerIntervalSecondsPreferenceKey,
          timerConfig.intervalSeconds ?? 60,
        );
        await preferences.setInt(
          _timerRoundsPreferenceKey,
          timerConfig.rounds ?? 10,
        );
        await preferences.remove(_timerTotalSecondsPreferenceKey);
        break;
      case WorkoutTimerType.amrap:
      case WorkoutTimerType.forTime:
        await preferences.setInt(
          _timerTotalSecondsPreferenceKey,
          timerConfig.totalSeconds ?? 0,
        );
        await preferences.remove(_timerIntervalSecondsPreferenceKey);
        await preferences.remove(_timerRoundsPreferenceKey);
        break;
    }
  }

  Future<void> _startRecording() async {
    if (!_controller.value.isInitialized || _isRecording) return;

    try {
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
        _elapsed = Duration.zero;
      });
      _startCountdownOrTimer();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(
        AppLocalizations.of(context).errorStartingRecording(e.toString()),
      );
    }
  }

  Future<void> _stopRecording() async {
    if (!_controller.value.isInitialized || !_isRecording) return;
    final l10n = AppLocalizations.of(context);

    try {
      final XFile videoFile = await _controller.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isProcessingVideo = true;
      });
      _stopTimerTicker(resetElapsed: false);
      _stopCountdown(resetRemaining: true);
      unawaited(_stopNativeBeep());

      final newFilePath = '${path.withoutExtension(videoFile.path)}.mp4';
      await File(videoFile.path).rename(newFilePath);
      final processedPath = await _embedOverlayInVideo(newFilePath);

      await Gal.putVideo(processedPath);
      if (!mounted) return;
      _showSnackBar(l10n.videoSaved);
    } on GalException {
      if (!mounted) return;
      _showErrorSnackBar(l10n.failedSaveVideo);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(l10n.errorStoppingRecording(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingVideo = false;
        });
      }
    }
  }

  Future<String> _embedOverlayInVideo(String inputPath) async {
    if (!_hasOverlayContent) {
      return inputPath;
    }

    final outputPath = '${path.withoutExtension(inputPath)}_proof.mp4';
    final l10n = AppLocalizations.of(context);
    try {
      final result = await _videoOverlayChannel
          .invokeMethod<String>('embedOverlay', {
            'inputPath': inputPath,
            'outputPath': outputPath,
            'athleteName': _athleteName,
            'eventName': _eventName,
            'workoutTitle': _workoutTitle,
            'timerType': _timerConfig?.type.name,
            'timerIntervalSeconds': _timerConfig?.intervalSeconds,
            'timerRounds': _timerConfig?.rounds,
            'timerTotalSeconds': _timerConfig?.totalSeconds,
            'countdownSeconds': _countdownSeconds,
            'eventLabel': l10n.event,
            'athleteLabel': l10n.athlete,
            'workoutLabel': l10n.workout,
            'roundLabel': l10n.round,
            'countdownLabel': l10n.countdown,
            'startsInLabel': l10n.startsIn,
            'nextStartLabel': l10n.nextStartLabel,
            'elapsedLabel': l10n.elapsed,
            'remainingLabel': l10n.remaining,
            'remainingSuffix': l10n.remainingLowercase,
            'elapsedSuffix': l10n.elapsedLowercase,
          });

      return result ?? outputPath;
    } on MissingPluginException {
      return inputPath;
    }
  }

  bool get _hasOverlayContent =>
      _athleteName.isNotEmpty ||
      _eventName.isNotEmpty ||
      _workoutTitle.isNotEmpty ||
      _timerConfig != null ||
      _countdownSeconds > 0;

  void _startCountdownOrTimer() {
    if (_countdownSeconds > 0) {
      _startCountdown();
    } else {
      _startTimerTicker();
    }
  }

  void _startCountdown() {
    _stopTimerTicker(resetElapsed: true);
    _countdownTicker?.cancel();
    setState(() {
      _isCountingDown = true;
      _countdownRemaining = _countdownSeconds;
    });
    unawaited(_playNativeBeep(_countdownBeepDuration));

    _countdownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownRemaining <= 1) {
        timer.cancel();
        _countdownTicker = null;
        setState(() {
          _isCountingDown = false;
          _countdownRemaining = 0;
        });
        unawaited(_playNativeBeep(_startBeepDuration));
        _startTimerTicker();
        return;
      }

      setState(() {
        _countdownRemaining -= 1;
      });
      unawaited(_playNativeBeep(_countdownBeepDuration));
    });
  }

  void _stopCountdown({bool resetRemaining = true}) {
    _countdownTicker?.cancel();
    _countdownTicker = null;
    if (resetRemaining) {
      setState(() {
        _isCountingDown = false;
        _countdownRemaining = 0;
      });
    }
  }

  Future<void> _playNativeBeep(Duration duration) async {
    try {
      await _beepChannel.invokeMethod<void>('playBeep', {
        'durationMs': duration.inMilliseconds,
      });
    } on MissingPluginException {
      // Recording should still work if native audio cues are unavailable.
    } on PlatformException {
      // Recording should still work if native audio cues are unavailable.
    }
  }

  Future<void> _stopNativeBeep() async {
    try {
      await _beepChannel.invokeMethod<void>('stopBeep');
    } on MissingPluginException {
      // Recording should still work if native audio cues are unavailable.
    } on PlatformException {
      // Recording should still work if native audio cues are unavailable.
    }
  }

  void _startTimerTicker() {
    _ticker?.cancel();
    _elapsed = Duration.zero;

    final config = _timerConfig;
    if (config == null) {
      setState(() {});
      return;
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });

      if (_shouldStopTimer(config, _elapsed)) {
        timer.cancel();
      }
    });
  }

  void _stopTimerTicker({bool resetElapsed = true}) {
    _ticker?.cancel();
    _ticker = null;
    if (resetElapsed) {
      setState(() {
        _elapsed = Duration.zero;
      });
    }
  }

  bool _shouldStopTimer(TimerConfiguration config, Duration elapsed) {
    switch (config.type) {
      case WorkoutTimerType.emom:
        final rounds = config.rounds;
        final interval = config.intervalSeconds;
        if (rounds != null && interval != null) {
          final totalSeconds = rounds * interval;
          return elapsed.inSeconds >= totalSeconds;
        }
        return false;
      case WorkoutTimerType.amrap:
      case WorkoutTimerType.forTime:
        final total = config.totalSeconds;
        if (total != null && total > 0) {
          return elapsed.inSeconds >= total;
        }
        return false;
    }
  }

  Future<void> _openSettingsSheet() async {
    final athleteName = _athleteName.trim().isNotEmpty
        ? _athleteName
        : widget.initialAthleteName.trim();

    final result = await showModalBottomSheet<RecorderSettings>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => RecorderSettingsSheet(
        athleteName: athleteName,
        eventName: _eventName,
        workoutTitle: _workoutTitle,
        countdownSeconds: _countdownSeconds,
        timerConfiguration: _timerConfig,
      ),
    );

    if (result == null) return;

    setState(() {
      _athleteName = result.athleteName.trim();
      _eventName = result.eventName.trim();
      _workoutTitle = result.workoutTitle.trim();
      _timerConfig = result.timerConfiguration;
      _countdownSeconds = result.countdownSeconds;
      _elapsed = Duration.zero;
      _countdownRemaining = 0;
      _isCountingDown = false;
    });
    await _storeSettings();

    _ticker?.cancel();
    _countdownTicker?.cancel();
    if (_isRecording) {
      _startCountdownOrTimer();
    }
  }

  Future<void> _clearOverlay() async {
    if (_isRecording) {
      _showErrorSnackBar(AppLocalizations.of(context).stopBeforeClearing);
      return;
    }

    setState(() {
      _athleteName = '';
      _eventName = '';
      _workoutTitle = '';
      _timerConfig = null;
      _countdownSeconds = 0;
      _elapsed = Duration.zero;
      _countdownRemaining = 0;
      _isCountingDown = false;
    });
    _countdownTicker?.cancel();
    _ticker?.cancel();
    await _storeSettings();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  Widget _buildCameraPreview() {
    return Center(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.previewSize!.width,
          height: _controller.value.previewSize!.height,
          child: CameraPreview(_controller),
        ),
      ),
    );
  }

  Widget _buildMetadataOverlay(BuildContext context) {
    final hasAthlete = _athleteName.isNotEmpty;
    final hasEvent = _eventName.isNotEmpty;
    final hasWorkout = _workoutTitle.isNotEmpty;
    final l10n = AppLocalizations.of(context);

    if (!hasAthlete && !hasEvent && !hasWorkout) {
      return const SizedBox.shrink();
    }

    final lines = <_OverlayLine>[
      if (hasAthlete) _OverlayLine(l10n.athlete, _athleteName),
      if (hasEvent) _OverlayLine(l10n.event, _eventName),
      if (hasWorkout) _OverlayLine(l10n.workout, _workoutTitle),
    ];

    return _ProofOverlayPanel(alignment: Alignment.bottomLeft, lines: lines);
  }

  Widget _buildTimerOverlay(BuildContext context) {
    final config = _timerConfig;
    if (config == null && !_isCountingDown) {
      return const SizedBox.shrink();
    }

    final lines = _previewTimerLines(context);

    return _ProofOverlayPanel(alignment: Alignment.bottomRight, lines: lines);
  }

  List<_OverlayLine> _previewTimerLines(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isCountingDown) {
      return [
        _OverlayLine(l10n.countdown, l10n.startsIn),
        _OverlayLine(l10n.remaining, '${_countdownRemaining}s'),
      ];
    }

    final config = _timerConfig;
    if (config == null) return const [];

    switch (config.type) {
      case WorkoutTimerType.emom:
        final interval = config.intervalSeconds ?? 60;
        final rounds = config.rounds ?? 0;
        final roundIndex = (_elapsed.inSeconds ~/ interval) + 1;
        final currentRound = rounds > 0
            ? math.min(roundIndex, rounds)
            : roundIndex;
        final primary = rounds > 0
            ? '${l10n.round} $currentRound/$rounds'
            : '${l10n.round} $currentRound';
        final withinInterval = _elapsed.inSeconds % interval;
        final remaining = Duration(
          seconds: math.max(interval - withinInterval, 0),
        );
        return [
          _OverlayLine(l10n.emomTitle, primary),
          _OverlayLine(l10n.nextStartLabel, _formatDuration(remaining)),
          _OverlayLine(l10n.elapsed, _formatDuration(_elapsed)),
        ];
      case WorkoutTimerType.amrap:
        final total = config.totalSeconds ?? 0;
        final remaining = Duration(
          seconds: math.max(total - _elapsed.inSeconds, 0),
        );
        return [
          _OverlayLine(
            l10n.amrapTitle,
            '${_formatDuration(remaining)} ${l10n.remainingLowercase}',
          ),
          _OverlayLine(l10n.elapsed, _formatDuration(_elapsed)),
        ];
      case WorkoutTimerType.forTime:
        final total = config.totalSeconds ?? 0;
        final remaining = Duration(
          seconds: math.max(total - _elapsed.inSeconds, 0),
        );
        return [
          _OverlayLine(
            l10n.forTimeTitle,
            '${_formatDuration(_elapsed)} ${l10n.elapsedLowercase}',
          ),
          _OverlayLine(l10n.remaining, _formatDuration(remaining)),
        ];
    }
  }

  Widget _buildRecordingBadge() {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: _isRecording || _isProcessingVideo ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: Padding(
            padding: const EdgeInsets.only(top: 90),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.45),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.fiber_manual_record,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isProcessingVideo ? l10n.saving : l10n.rec,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCameraPreview(),
          _buildMetadataOverlay(context),
          _buildTimerOverlay(context),
          _buildRecordingBadge(),
          _buildTopActions(context),
          _buildRecordControl(),
        ],
      ),
    );
  }

  Widget _buildTopActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ControlButton(
                    icon: Icons.badge_rounded,
                    label: l10n.details,
                    onPressed: _isRecording || _isProcessingVideo
                        ? null
                        : _openSettingsSheet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ControlButton(
                    icon: Icons.restart_alt_rounded,
                    label: l10n.reset,
                    onPressed:
                        _isRecording ||
                            _isProcessingVideo ||
                            (_athleteName.isEmpty &&
                                _eventName.isEmpty &&
                                _workoutTitle.isEmpty &&
                                _timerConfig == null &&
                                _countdownSeconds <= 0)
                        ? null
                        : _clearOverlay,
                    tone: ControlButtonTone.subtle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordControl() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: _RecordButton(
            isRecording: _isRecording,
            onPressed: _isProcessingVideo
                ? null
                : _isRecording
                ? _stopRecording
                : _startRecording,
          ),
        ),
      ),
    );
  }
}

class _OverlayLine {
  const _OverlayLine(this.label, this.value);

  final String label;
  final String value;
}

class _ProofOverlayPanel extends StatelessWidget {
  const _ProofOverlayPanel({required this.alignment, required this.lines});

  final Alignment alignment;
  final List<_OverlayLine> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    return Align(
      alignment: alignment,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final panelWidth = math.min(availableWidth * 0.38, 220.0);
          return Padding(
            padding: const EdgeInsets.all(14),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: math.min(panelWidth, availableWidth),
                maxWidth: math.min(panelWidth, availableWidth),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withValues(alpha: 0.59),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 0.8,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var index = 0; index < lines.length; index++) ...[
                        if (index > 0) const SizedBox(height: 8),
                        Text(
                          lines[index].label.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: _clampedTextScaler(textScaler),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.68),
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          lines[index].value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textScaler: _clampedTextScaler(textScaler),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  TextScaler _clampedTextScaler(TextScaler scaler) {
    final value = scaler.scale(1).clamp(1.0, 1.15).toDouble();
    return TextScaler.linear(value);
  }
}

enum ControlButtonTone { primary, subtle }

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tone = ControlButtonTone.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final ControlButtonTone tone;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final background = tone == ControlButtonTone.primary
        ? Colors.white.withValues(alpha: isEnabled ? 0.15 : 0.05)
        : Colors.white.withValues(alpha: isEnabled ? 0.08 : 0.04);
    final borderColor = Colors.white.withValues(alpha: 0.12);
    final foreground = Colors.white.withValues(alpha: isEnabled ? 0.9 : 0.4);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: background,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.isRecording, required this.onPressed});

  final bool isRecording;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: onPressed == null ? 0.04 : 0.1),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: onPressed == null ? 0.08 : 0.25,
            ),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isRecording
                  ? Colors.redAccent.withValues(alpha: 0.45)
                  : Colors.black.withValues(alpha: 0.45),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: isRecording ? 34 : 56,
            height: isRecording ? 34 : 56,
            decoration: BoxDecoration(
              color: isRecording ? Colors.redAccent : Colors.white,
              borderRadius: BorderRadius.circular(isRecording ? 10 : 999),
            ),
          ),
        ),
      ),
    );
  }
}

enum TimerTypeOption { none, emom, amrap, forTime }

class RecorderSettingsSheet extends StatefulWidget {
  const RecorderSettingsSheet({
    super.key,
    required this.athleteName,
    required this.eventName,
    required this.workoutTitle,
    required this.countdownSeconds,
    this.timerConfiguration,
  });

  final String athleteName;
  final String eventName;
  final String workoutTitle;
  final int countdownSeconds;
  final TimerConfiguration? timerConfiguration;

  @override
  State<RecorderSettingsSheet> createState() => _RecorderSettingsSheetState();
}

class _RecorderSettingsSheetState extends State<RecorderSettingsSheet> {
  late final TextEditingController _athleteController;
  late final TextEditingController _eventController;
  late final TextEditingController _workoutController;
  late final TextEditingController _durationController;
  late final TextEditingController _intervalController;
  late final TextEditingController _roundsController;
  late final TextEditingController _countdownController;

  final _formKey = GlobalKey<FormState>();
  TimerTypeOption _selectedTimerType = TimerTypeOption.none;

  @override
  void initState() {
    super.initState();
    _athleteController = TextEditingController(text: widget.athleteName);
    _eventController = TextEditingController(text: widget.eventName);
    _workoutController = TextEditingController(text: widget.workoutTitle);
    _durationController = TextEditingController();
    _intervalController = TextEditingController();
    _roundsController = TextEditingController();
    _countdownController = TextEditingController(
      text: widget.countdownSeconds.toString(),
    );

    final timer = widget.timerConfiguration;
    if (timer != null) {
      switch (timer.type) {
        case WorkoutTimerType.amrap:
          _selectedTimerType = TimerTypeOption.amrap;
          _durationController.text = _secondsToMinutes(timer.totalSeconds);
          break;
        case WorkoutTimerType.forTime:
          _selectedTimerType = TimerTypeOption.forTime;
          _durationController.text = _secondsToMinutes(timer.totalSeconds);
          break;
        case WorkoutTimerType.emom:
          _selectedTimerType = TimerTypeOption.emom;
          _intervalController.text = (timer.intervalSeconds ?? 60).toString();
          _roundsController.text = (timer.rounds ?? 10).toString();
          break;
      }
    }
  }

  @override
  void dispose() {
    _athleteController.dispose();
    _eventController.dispose();
    _workoutController.dispose();
    _durationController.dispose();
    _intervalController.dispose();
    _roundsController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  String _secondsToMinutes(int? seconds) {
    if (seconds == null || seconds <= 0) return '';
    final minutes = seconds / 60;
    if (minutes % 1 == 0) {
      return minutes.toInt().toString();
    }
    return minutes.toStringAsFixed(1);
  }

  int _minutesFieldToSeconds(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.')) ?? 0;
    return (parsed * 60).round();
  }

  InputDecoration _inputDecoration(String hint) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.transparent),
    );
    return InputDecoration(
      hintText: hint.isEmpty ? null : hint,
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 1.4),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12),
    );
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    TimerConfiguration? timerConfig;
    switch (_selectedTimerType) {
      case TimerTypeOption.none:
        timerConfig = null;
        break;
      case TimerTypeOption.amrap:
        final seconds = _minutesFieldToSeconds(_durationController.text);
        timerConfig = TimerConfiguration(
          type: WorkoutTimerType.amrap,
          totalSeconds: seconds,
        );
        break;
      case TimerTypeOption.forTime:
        final seconds = _minutesFieldToSeconds(_durationController.text);
        timerConfig = TimerConfiguration(
          type: WorkoutTimerType.forTime,
          totalSeconds: seconds,
        );
        break;
      case TimerTypeOption.emom:
        final interval = int.parse(_intervalController.text);
        final rounds = int.parse(_roundsController.text);
        timerConfig = TimerConfiguration(
          type: WorkoutTimerType.emom,
          intervalSeconds: interval,
          rounds: rounds,
        );
        break;
    }

    Navigator.of(context).pop(
      RecorderSettings(
        athleteName: _athleteController.text,
        eventName: _eventController.text,
        workoutTitle: _workoutController.text,
        countdownSeconds: int.parse(_countdownController.text),
        timerConfiguration: timerConfig,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.recordingDetails,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FormFieldLabel(text: l10n.athleteName),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _athleteController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(l10n.athleteNameHint),
                    ),
                    const SizedBox(height: 16),
                    _FormFieldLabel(text: l10n.eventName),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _eventController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(l10n.eventNameHint),
                    ),
                    const SizedBox(height: 16),
                    _FormFieldLabel(text: l10n.workoutQualifierTitle),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _workoutController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(l10n.workoutTitleHint),
                    ),
                    const SizedBox(height: 16),
                    _FormFieldLabel(
                      text: l10n.countdownSeconds,
                      caption: l10n.countdownCaption,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _countdownController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(l10n.secondsExampleHint),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.enterCountdownSeconds;
                        }
                        final parsed = int.tryParse(value);
                        if (parsed == null || parsed < 0) {
                          return l10n.countdownNonNegative;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.timerTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _FormFieldLabel(
                      text: l10n.timerType,
                      caption: l10n.timerTypeCaption,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<TimerTypeOption>(
                      initialValue: _selectedTimerType,
                      isExpanded: true,
                      decoration: _inputDecoration(l10n.selectTimerType),
                      items: [
                        DropdownMenuItem(
                          value: TimerTypeOption.none,
                          child: Text(l10n.noTimerOverlay),
                        ),
                        DropdownMenuItem(
                          value: TimerTypeOption.emom,
                          child: Text(l10n.emomTitle),
                        ),
                        DropdownMenuItem(
                          value: TimerTypeOption.amrap,
                          child: Text(l10n.amrapTitle),
                        ),
                        DropdownMenuItem(
                          value: TimerTypeOption.forTime,
                          child: Text(l10n.forTimeTitle),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedTimerType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _buildTimerFields(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _handleSave,
                        icon: const Icon(Icons.check),
                        label: Text(l10n.saveSettings),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        label: Text(l10n.cancel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerFields() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedTimerType) {
      case TimerTypeOption.none:
        return Container(
          key: const ValueKey('timer-none'),
          padding: const EdgeInsets.all(16),
          decoration: _panelDecoration(),
          child: Text(l10n.noTimerOverlayMessage),
        );
      case TimerTypeOption.emom:
        return Container(
          key: const ValueKey('timer-emom'),
          padding: const EdgeInsets.all(16),
          decoration: _panelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FormFieldLabel(
                text: l10n.intervalLengthSeconds,
                caption: l10n.intervalLengthSecondsHelper,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(l10n.secondsExampleHint),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.enterIntervalLength;
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return l10n.intervalPositive;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _FormFieldLabel(text: l10n.rounds, caption: l10n.roundsCaption),
              const SizedBox(height: 8),
              TextFormField(
                controller: _roundsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(l10n.roundsExampleHint),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.enterRounds;
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return l10n.roundsPositive;
                  }
                  return null;
                },
              ),
            ],
          ),
        );
      case TimerTypeOption.amrap:
        return _buildMinutesField(
          key: const ValueKey('timer-amrap'),
          label: l10n.durationMinutes,
          helper: l10n.durationMinutesHelper,
        );
      case TimerTypeOption.forTime:
        return _buildMinutesField(
          key: const ValueKey('timer-for-time'),
          label: l10n.timeCapMinutes,
          helper: l10n.timeCapMinutesHelper,
        );
    }
  }

  Widget _buildMinutesField({
    required Key key,
    required String label,
    required String helper,
  }) {
    final l10n = AppLocalizations.of(context);
    return Container(
      key: key,
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormFieldLabel(text: label, caption: helper),
          const SizedBox(height: 8),
          TextFormField(
            controller: _durationController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration(l10n.minutesExampleHint),
            validator: (value) {
              final l10n = AppLocalizations.of(context);
              if (value == null || value.isEmpty) {
                return l10n.enterDurationMinutes;
              }
              final parsed = double.tryParse(value.replaceAll(',', '.'));
              if (parsed == null || parsed <= 0) {
                return l10n.durationPositive;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _FormFieldLabel extends StatelessWidget {
  const _FormFieldLabel({required this.text, this.caption});

  final String text;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 4),
          Text(
            caption!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}
