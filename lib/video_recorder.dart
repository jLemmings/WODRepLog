
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const MethodChannel _videoOverlayChannel = MethodChannel('wodreplog/video_overlay');

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
    this.timerConfiguration,
  });

  final String athleteName;
  final String eventName;
  final String workoutTitle;
  final TimerConfiguration? timerConfiguration;
}

class VideoRecorder extends StatefulWidget {
  const VideoRecorder({super.key});

  @override
  VideoRecorderState createState() => VideoRecorderState();
}

class VideoRecorderState extends State<VideoRecorder> {
  late CameraController _controller;
  bool _isRecording = false;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  final GlobalKey _overlayBoundaryKey = GlobalKey();
  bool _isProcessingVideo = false;

  String _athleteName = '';
  String _eventName = '';
  String _workoutTitle = '';
  TimerConfiguration? _timerConfig;

  bool get _hasOverlayContent =>
      _athleteName.isNotEmpty ||
      _eventName.isNotEmpty ||
      _workoutTitle.isNotEmpty ||
      _timerConfig != null;
  @override
  void initState() {
    super.initState();
    _initializeCamera();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
      _showErrorSnackBar('Failed to initialize camera: $e');
    }
  }

  Future<void> _startRecording() async {
    if (!_controller.value.isInitialized || _isRecording || _isProcessingVideo) return;

    try {
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
      _startTimerTicker();
    } catch (e) {
      _showErrorSnackBar('Error starting video recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_controller.value.isInitialized || !_isRecording) return;

    try {
      final XFile videoFile = await _controller.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _isProcessingVideo = true;
      });
      _stopTimerTicker(resetElapsed: false);

      final newFilePath = '${path.withoutExtension(videoFile.path)}.mp4';
      final File renamedFile = await File(videoFile.path).rename(newFilePath);

      if (_hasOverlayContent) {
        _showSnackBar('Applying overlay to video...');
      }
      final processedPath = await _processVideoWithOverlay(renamedFile.path);

      final bool? success = await GallerySaver.saveVideo(processedPath);
      if (success == true) {
        _showSnackBar('Video saved to gallery');
      } else {
        _showErrorSnackBar('Failed to save video to gallery');
      }
    } catch (e) {
      _showErrorSnackBar('Error stopping video recording: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingVideo = false;
        });
      } else {
        _isProcessingVideo = false;
      }
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
    final result = await showModalBottomSheet<RecorderSettings>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => RecorderSettingsSheet(
        athleteName: _athleteName,
        eventName: _eventName,
        workoutTitle: _workoutTitle,
        timerConfiguration: _timerConfig,
      ),
    );

    if (result == null) return;

    setState(() {
      _athleteName = result.athleteName.trim();
      _eventName = result.eventName.trim();
      _workoutTitle = result.workoutTitle.trim();
      _timerConfig = result.timerConfiguration;
      _elapsed = Duration.zero;
    });

    _ticker?.cancel();
    if (_isRecording) {
      _startTimerTicker();
    }
  }

  void _clearOverlay() {
    if (_isRecording) {
      _showErrorSnackBar('Stop recording before clearing the overlay.');
      return;
    }

    setState(() {
      _athleteName = '';
      _eventName = '';
      _workoutTitle = '';
      _timerConfig = null;
      _elapsed = Duration.zero;
    });
    _ticker?.cancel();
  }
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _timerPrimaryText() {
    final config = _timerConfig;
    if (config == null) return 'Timer inactive';

    switch (config.type) {
      case WorkoutTimerType.emom:
        final interval = config.intervalSeconds ?? 60;
        final rounds = config.rounds ?? 0;
        final roundIndex = (_elapsed.inSeconds ~/ interval) + 1;
        final currentRound = rounds > 0
            ? math.min(roundIndex, rounds)
            : roundIndex;
        final roundLabel = rounds > 0
            ? '$currentRound/$rounds'
            : '$currentRound';
        return 'EMOM • Round $roundLabel';
      case WorkoutTimerType.amrap:
        final total = config.totalSeconds ?? 0;
        final remaining = Duration(seconds: math.max(total - _elapsed.inSeconds, 0));
        return 'AMRAP • ${_formatDuration(remaining)} remaining';
      case WorkoutTimerType.forTime:
        return 'For Time • ${_formatDuration(_elapsed)} elapsed';
    }
  }

  String? _timerSecondaryText() {
    final config = _timerConfig;
    if (config == null) return null;

    switch (config.type) {
      case WorkoutTimerType.emom:
        final interval = config.intervalSeconds ?? 60;
        final withinInterval = _elapsed.inSeconds % interval;
        final intervalRemaining = Duration(seconds: math.max(interval - withinInterval, 0));
        return 'Next start in ${_formatDuration(intervalRemaining)}';
      case WorkoutTimerType.amrap:
        final total = config.totalSeconds;
        if (total == null) return null;
        return 'Cap ${_formatDuration(Duration(seconds: total))}';
      case WorkoutTimerType.forTime:
        final total = config.totalSeconds;
        if (total == null) return null;
        final remaining = Duration(seconds: math.max(total - _elapsed.inSeconds, 0));
        return 'Target ${_formatDuration(Duration(seconds: total))} • ${_formatDuration(remaining)} remaining';
    }
  }

  double? _timerProgress() {
    final config = _timerConfig;
    if (config == null) return null;

    switch (config.type) {
      case WorkoutTimerType.emom:
        final totalRoundSeconds = (config.intervalSeconds ?? 0) * (config.rounds ?? 0);
        if (totalRoundSeconds <= 0) return null;
        return (_elapsed.inSeconds / totalRoundSeconds).clamp(0, 1);
      case WorkoutTimerType.amrap:
      case WorkoutTimerType.forTime:
        final total = config.totalSeconds ?? 0;
        if (total <= 0) return null;
        return (_elapsed.inSeconds / total).clamp(0, 1);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
  Widget _buildCameraPreview() {
    return Center(
      child: Transform.rotate(
        angle: math.pi,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.previewSize!.width,
            height: _controller.value.previewSize!.height,
            child: CameraPreview(_controller),
          ),
        ),
      ),
    );
  }

  BoxDecoration _overlayDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: Colors.black.withValues(alpha: 0.38),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Future<String> _processVideoWithOverlay(String videoPath) async {
    if (!_hasOverlayContent) {
      return videoPath;
    }

    File? overlayImage;
    try {
      overlayImage = await _captureOverlayImage();
      if (overlayImage == null) {
        return videoPath;
      }

      final overlayedPath = await _composeVideoWithOverlay(videoPath, overlayImage.path);
      if (overlayedPath == null) {
        return videoPath;
      }

      final originalFile = File(videoPath);
      if (originalFile.existsSync()) {
        try {
          await originalFile.delete();
        } catch (e) {
          debugPrint('Unable to delete original video before replacing overlay: $e');
        }
      }

      try {
        final renamed = await File(overlayedPath).rename(videoPath);
        return renamed.path;
      } on FileSystemException {
        final copied = await File(overlayedPath).copy(videoPath);
        try {
          await File(overlayedPath).delete();
        } catch (_) {}
        return copied.path;
      }
    } catch (e) {
      debugPrint('Failed to process overlay: $e');
      return videoPath;
    } finally {
      if (overlayImage != null && overlayImage.existsSync()) {
        try {
          await overlayImage.delete();
        } catch (_) {}
      }
    }
  }

  Future<File?> _captureOverlayImage() async {
    if (!_hasOverlayContent) return null;

    final pixelRatio = math.max(2.0, MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.5);

    await Future.delayed(Duration.zero);
    if (!mounted) return null;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return null;

    final boundary = _overlayBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }

    if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 16));
    }

    try {
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final tempDir = await getTemporaryDirectory();
      final overlayPath = path.join(
        tempDir.path,
        'overlay_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      final file = File(overlayPath);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file;
    } catch (e) {
      debugPrint('Unable to capture overlay image: $e');
      return null;
    }
  }

  Future<String?> _composeVideoWithOverlay(String videoPath, String overlayImagePath) async {
    if (!Platform.isAndroid) {
      debugPrint('Overlay composition currently supported on Android only.');
      return null;
    }

    final tempDir = await getTemporaryDirectory();
    final outputPath = path.join(
      tempDir.path,
      'overlay_video_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    try {
      final composedPath = await _videoOverlayChannel.invokeMethod<String>(
        'applyOverlay',
        <String, dynamic>{
          'videoPath': videoPath,
          'overlayPath': overlayImagePath,
          'outputPath': outputPath,
          'marginLeft': 24,
          'marginBottom': 24,
        },
      );
      return composedPath;
    } on PlatformException catch (e, stack) {
      debugPrint('Overlay composition failed: ${e.message}');
      debugPrint('$stack');
      return null;
    } catch (e) {
      debugPrint('Unexpected overlay composition error: $e');
      return null;
    }
  }

  Widget _buildOverlayDetail(
    ThemeData theme, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ) ??
              TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayPanel(BuildContext context) {
    final theme = Theme.of(context);
    final showMetadata = _athleteName.isNotEmpty || _eventName.isNotEmpty || _workoutTitle.isNotEmpty;
    final hasTimer = _timerConfig != null;
    final children = <Widget>[];

    if (showMetadata) {
      if (_eventName.isNotEmpty) {
        children.add(_buildOverlayDetail(theme, label: 'Event', value: _eventName));
      }
      if (_athleteName.isNotEmpty) {
        if (children.isNotEmpty) {
          children.add(const SizedBox(height: 6));
        }
        children.add(_buildOverlayDetail(theme, label: 'Athlete', value: _athleteName));
      }
      if (_workoutTitle.isNotEmpty) {
        if (children.isNotEmpty) {
          children.add(const SizedBox(height: 6));
        }
        children.add(_buildOverlayDetail(theme, label: 'Workout', value: _workoutTitle));
      }
    }

    if (hasTimer) {
      if (children.isNotEmpty) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
        ));
      }
      final primary = _timerPrimaryText();
      final secondary = _timerSecondaryText();
      final progress = _timerProgress();

      children.add(Text(
        primary,
        style: theme.textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ));
      if (secondary != null) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            secondary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ));
      }
      children.add(Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          _formatDuration(_elapsed),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
      if (progress != null) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightGreenAccent),
              minHeight: 4,
            ),
          ),
        ));
      }
    }

    if (children.isEmpty) {
      children.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.white.withValues(alpha: 0.8), size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Tap Details to add overlay.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ));
    }

    return Align(
      alignment: Alignment.bottomLeft,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: RepaintBoundary(
            key: _overlayBoundaryKey,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 240),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: _overlayDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildRecordingBadge() {
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: _isRecording ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
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
                children: const [
                  Icon(Icons.fiber_manual_record, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'REC',
                    style: TextStyle(
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

  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Saving video...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
            ],
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
          _buildOverlayPanel(context),
          _buildRecordingBadge(),
          _buildControlBar(context),
          if (_isProcessingVideo) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildControlBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: _ControlButton(
                  icon: Icons.badge,
                  label: 'Details',
                  onPressed: _isProcessingVideo ? null : _openSettingsSheet,
                ),
              ),
              const SizedBox(width: 18),
              _RecordButton(
                isRecording: _isRecording,
                onPressed: _isProcessingVideo
                    ? null
                    : (_isRecording ? _stopRecording : _startRecording),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _ControlButton(
                  icon: Icons.layers_clear,
                  label: 'Reset',
                  onPressed: _isProcessingVideo ||
                          (_athleteName.isEmpty &&
                              _eventName.isEmpty &&
                              _workoutTitle.isEmpty &&
                              _timerConfig == null)
                      ? null
                      : _clearOverlay,
                  tone: ControlButtonTone.subtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            borderRadius: BorderRadius.circular(14),
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
  const _RecordButton({
    required this.isRecording,
    required this.onPressed,
  });

  final bool isRecording;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final outerColor = Colors.white.withValues(alpha: isEnabled ? 0.1 : 0.05);
    final borderColor = Colors.white.withValues(alpha: isEnabled ? 0.25 : 0.12);
    final shadowColor = isRecording
        ? Colors.redAccent.withValues(alpha: isEnabled ? 0.45 : 0.2)
        : Colors.black.withValues(alpha: isEnabled ? 0.45 : 0.25);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1 : 0.6,
      child: GestureDetector(
        onTap: isEnabled ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: outerColor,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isRecording ? 36 : 60,
              height: isRecording ? 36 : 60,
              decoration: BoxDecoration(
                color: isRecording ? Colors.redAccent : Colors.white,
                borderRadius: BorderRadius.circular(isRecording ? 10 : 999),
              ),
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
    this.timerConfiguration,
  });

  final String athleteName;
  final String eventName;
  final String workoutTitle;
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

  InputDecoration _inputDecoration(
    String hint, {
    String? label,
    bool hasValue = false,
  }) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.transparent),
    );
    return InputDecoration(
      hintText: hint.isEmpty ? null : hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.45),
      ),
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.78),
      ),
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFF4FC3F7), width: 1.4),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: hasValue
          ? const Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: Color(0xFF7CFFB2),
            )
          : null,
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(12),
    );
  }

  BoxDecoration _sheetDecoration(ThemeData theme) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 30,
          offset: const Offset(0, 24),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasValue = value.text.trim().isNotEmpty;
        return TextFormField(
          controller: controller,
          textCapitalization: capitalization,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
          cursorColor: Colors.lightBlueAccent,
          decoration: _inputDecoration(
            hint,
            label: label,
            hasValue: hasValue,
          ),
        );
      },
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
        timerConfiguration: timerConfig,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: DecoratedBox(
                decoration: _sheetDecoration(theme),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Recording Details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _athleteController,
                          label: 'Athlete name',
                          hint: 'e.g. Sam Briggs',
                          capitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _eventController,
                          label: 'Event name',
                          hint: 'e.g. Wodapalooza Qualifier',
                          capitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _workoutController,
                          label: 'Workout / qualifier title',
                          hint: 'e.g. Qualifier 1 - Heavy Grace',
                          capitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Timer overlay',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        const _FormFieldLabel(
                          text: 'Timer type',
                          caption: 'Choose a format to overlay alongside the recording.',
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<TimerTypeOption>(
                          initialValue: _selectedTimerType,
                          isExpanded: true,
                          decoration: _inputDecoration(
                            'Select timer type',
                            label: 'Timer type',
                            hasValue: _selectedTimerType != TimerTypeOption.none,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: TimerTypeOption.none,
                              child: Text('No timer overlay'),
                            ),
                            DropdownMenuItem(
                              value: TimerTypeOption.emom,
                              child: Text('EMOM'),
                            ),
                            DropdownMenuItem(
                              value: TimerTypeOption.amrap,
                              child: Text('AMRAP'),
                            ),
                            DropdownMenuItem(
                              value: TimerTypeOption.forTime,
                              child: Text('For Time'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedTimerType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _buildTimerFields(),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _handleSave,
                            icon: const Icon(Icons.check),
                            label: const Text('Save settings'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerFields() {
    switch (_selectedTimerType) {
      case TimerTypeOption.none:
        return Container(
          key: const ValueKey('timer-none'),
          padding: const EdgeInsets.all(16),
          decoration: _panelDecoration(),
          child: const Text(
            'No timer overlay will be shown. You can still start and stop recording normally.',
          ),
        );
      case TimerTypeOption.emom:
        return Container(
          key: const ValueKey('timer-emom'),
          padding: const EdgeInsets.all(16),
          decoration: _panelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _intervalController,
                builder: (context, value, _) => TextFormField(
                  controller: _intervalController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    'e.g. 60',
                    label: 'Interval length (seconds)',
                    hasValue: value.text.trim().isNotEmpty,
                  ),
                  validator: (input) {
                    if (input == null || input.isEmpty) {
                      return 'Enter the interval length';
                    }
                    final parsed = int.tryParse(input);
                    if (parsed == null || parsed <= 0) {
                      return 'Interval must be a positive number';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Length of each work period before the next start.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _roundsController,
                builder: (context, value, _) => TextFormField(
                  controller: _roundsController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    'e.g. 12',
                    label: 'Rounds',
                    hasValue: value.text.trim().isNotEmpty,
                  ),
                  validator: (input) {
                    if (input == null || input.isEmpty) {
                      return 'Enter number of rounds';
                    }
                    final parsed = int.tryParse(input);
                    if (parsed == null || parsed <= 0) {
                      return 'Rounds must be a positive number';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'How many intervals the EMOM should run.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                ),
              ),
            ],
          ),
        );
      case TimerTypeOption.amrap:
        return _buildMinutesField(
          key: const ValueKey('timer-amrap'),
          label: 'Duration (minutes)',
          helper: 'Timer counts down from the duration you set.',
        );
      case TimerTypeOption.forTime:
        return _buildMinutesField(
          key: const ValueKey('timer-for-time'),
          label: 'Time cap (minutes)',
          helper: 'Timer counts up, showing the time cap and remaining time.',
        );
    }
  }

  Widget _buildMinutesField({
    required Key key,
    required String label,
    required String helper,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      key: key,
      valueListenable: _durationController,
      builder: (context, value, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: _panelDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FormFieldLabel(
              text: label,
              caption: helper,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _durationController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration(
                'e.g. 20',
                label: label,
                hasValue: value.text.trim().isNotEmpty,
              ),
              validator: (input) {
                if (input == null || input.isEmpty) {
                  return 'Enter a duration in minutes';
                }
                final parsed = double.tryParse(input.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return 'Provide a positive number of minutes';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FormFieldLabel extends StatelessWidget {
  const _FormFieldLabel({
    required this.text,
    this.caption,
  });

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
