import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path/path.dart' as path;

class VideoRecorder extends StatefulWidget {
  const VideoRecorder({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  VideoRecorderState createState() => VideoRecorderState();
}

class VideoRecorderState extends State<VideoRecorder> {
  CameraController? _controller;
  late final Future<void> _initializationFuture;
  String? _initializationError;

  bool _isRecording = false;
  bool _isProcessingVideo = false;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isTimerEnabled = false;
  bool _autoStopAtTarget = false;
  Duration? _targetDuration;

  String competitionName = '';
  String workoutName = '';

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeCamera();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _initializationError = null;
      });
    } on CameraException catch (error) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _controller = null;
        _initializationError = error.description ?? error.code;
      });
    } catch (error) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _controller = null;
        _initializationError = error.toString();
      });
    }
  }

  Future<void> _startRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      _showErrorSnackBar('Camera is not ready yet.');
      return;
    }

    if (_isProcessingVideo || controller.value.isRecordingVideo) {
      return;
    }

    try {
      try {
        await controller.prepareForVideoRecording();
      } catch (_) {
        // Some platforms do not require prepareForVideoRecording.
      }

      await controller.startVideoRecording();
      if (!mounted) return;

      setState(() {
        _isRecording = true;
        _elapsedSeconds = 0;
      });

      if (_isTimerEnabled) {
        _startTimer();
      }
    } catch (error) {
      _showErrorSnackBar('Error starting video recording: $error');
    }
  }

  Future<void> _stopRecording({bool autoStopped = false}) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (!controller.value.isRecordingVideo || _isProcessingVideo) {
      _clearTimerState();
      return;
    }

    setState(() {
      _isProcessingVideo = true;
    });

    try {
      final XFile videoFile = await controller.stopVideoRecording();
      if (!mounted) {
        _clearTimerState();
        return;
      }

      setState(() {
        _isRecording = false;
        _clearTimerState();
      });

      final newFilePath = '${path.withoutExtension(videoFile.path)}.mp4';
      final savedFile = await File(videoFile.path).rename(newFilePath);

      final bool? success = await GallerySaver.saveVideo(savedFile.path);
      if (!mounted) return;

      if (success == true) {
        _showSnackBar(
          autoStopped
              ? 'Recording stopped automatically and saved to gallery.'
              : 'Video saved to gallery.',
        );
      } else {
        _showErrorSnackBar('Failed to save video to gallery.');
      }
    } catch (error) {
      if (mounted) {
        _showErrorSnackBar('Error stopping video recording: $error');
      }
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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (!_isRecording) {
        timer.cancel();
        return;
      }

      setState(() {
        _elapsedSeconds++;
      });

      if (_autoStopAtTarget &&
          _targetDuration != null &&
          _elapsedSeconds >= _targetDuration!.inSeconds &&
          !_isProcessingVideo) {
        timer.cancel();
        _stopRecording(autoStopped: true);
      }
    });
  }

  void _clearTimerState() {
    _timer?.cancel();
    _timer = null;
    _elapsedSeconds = 0;
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

  Future<void> _showInputDialog() async {
    final details = await showDialog<_CompetitionDetails>(
      context: context,
      builder: (BuildContext context) {
        final competitionController =
            TextEditingController(text: competitionName);
        final workoutController = TextEditingController(text: workoutName);

        return AlertDialog(
          title: const Text('Overlay Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: competitionController,
                decoration: const InputDecoration(
                  labelText: 'Competition Name',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: workoutController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(
                  _CompetitionDetails(
                    competition: competitionController.text.trim(),
                    workout: workoutController.text.trim(),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (details != null && mounted) {
      setState(() {
        competitionName = details.competition;
        workoutName = details.workout;
      });
    }
  }

  Future<void> _showTimerConfigDialog() async {
    final formKey = GlobalKey<FormState>();
    bool timerEnabled = _isTimerEnabled;
    bool autoStop = _autoStopAtTarget;
    String? validationMessage;

    final minutesController = TextEditingController(
      text: _targetDuration != null
          ? _targetDuration!.inMinutes.toString()
          : '0',
    );
    final secondsController = TextEditingController(
      text: _targetDuration != null
          ? (_targetDuration!.inSeconds % 60).toString()
          : '0',
    );

    StateSetter? dialogSetState;

    final settings = await showDialog<_TimerSettings>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recording Timer'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              dialogSetState = setDialogState;
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show timer while recording'),
                      value: timerEnabled,
                      onChanged: (value) {
                        setDialogState(() {
                          timerEnabled = value;
                          validationMessage = null;
                        });
                      },
                    ),
                    if (timerEnabled) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: minutesController,
                              keyboardType: TextInputType.number,
                              decoration:
                                  const InputDecoration(labelText: 'Minutes'),
                              validator: (value) {
                                final parsed = int.tryParse(value ?? '');
                                if (parsed == null || parsed < 0) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: secondsController,
                              keyboardType: TextInputType.number,
                              decoration:
                                  const InputDecoration(labelText: 'Seconds'),
                              validator: (value) {
                                final parsed = int.tryParse(value ?? '');
                                if (parsed == null || parsed < 0 || parsed > 59) {
                                  return '0 - 59';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Stop automatically at target time'),
                        value: autoStop,
                        onChanged: (value) {
                          setDialogState(() {
                            autoStop = value;
                            validationMessage = null;
                          });
                        },
                      ),
                      if (validationMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            validationMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (timerEnabled && !formKey.currentState!.validate()) {
                  return;
                }

                final minutes = int.tryParse(minutesController.text) ?? 0;
                final seconds = int.tryParse(secondsController.text) ?? 0;

                if (timerEnabled && autoStop && minutes == 0 && seconds == 0) {
                  dialogSetState?.call(() {
                    validationMessage =
                        'Set a duration greater than zero for auto stop.';
                  });
                  return;
                }

                final durationSeconds = (minutes * 60) + seconds;
                Navigator.of(context).pop(
                  _TimerSettings(
                    enabled: timerEnabled,
                    autoStop: timerEnabled ? autoStop : false,
                    duration:
                        timerEnabled && durationSeconds > 0
                            ? Duration(seconds: durationSeconds)
                            : null,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (settings != null && mounted) {
      setState(() {
        _isTimerEnabled = settings.enabled;
        _autoStopAtTarget = settings.autoStop;
        _targetDuration = settings.duration;
      });
    }
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildCameraPreview() {
    if (_initializationError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _initializationError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializationFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              Positioned.fill(child: _buildCameraPreview()),
              if (competitionName.isNotEmpty)
                Positioned(
                  top: 24,
                  left: 24,
                  child: Text(
                    competitionName,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (workoutName.isNotEmpty)
                Positioned(
                  bottom: 24,
                  left: 24,
                  child: Text(
                    workoutName,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (_isRecording && _isTimerEnabled)
                Positioned(
                  top: 24,
                  right: 24,
                  child: _TimerChip(
                    elapsed: _elapsedSeconds,
                    target: _targetDuration?.inSeconds,
                    autoStop: _autoStopAtTarget,
                    formatter: _formatSeconds,
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton.small(
                heroTag: 'timer-config',
                onPressed: _isProcessingVideo ? null : _showTimerConfigDialog,
                child: const Icon(Icons.timer_outlined),
              ),
              FloatingActionButton(
                heroTag: 'record',
                onPressed: _isProcessingVideo
                    ? null
                    : _isRecording
                        ? () => _stopRecording()
                        : _startRecording,
                child: _isProcessingVideo
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        _isRecording
                            ? Icons.stop
                            : Icons.fiber_manual_record,
                      ),
              ),
              FloatingActionButton.small(
                heroTag: 'details',
                onPressed: _isProcessingVideo ? null : _showInputDialog,
                child: const Icon(Icons.edit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({
    required this.elapsed,
    required this.formatter,
    this.target,
    this.autoStop = false,
  });

  final int elapsed;
  final int? target;
  final bool autoStop;
  final String Function(int seconds) formatter;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer(formatter(elapsed));
    if (target != null) {
      buffer.write(' / ');
      buffer.write(formatter(target!));
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              buffer.toString(),
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (autoStop && target != null)
              const Text(
                'Auto stop enabled',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompetitionDetails {
  const _CompetitionDetails({
    required this.competition,
    required this.workout,
  });

  final String competition;
  final String workout;
}

class _TimerSettings {
  const _TimerSettings({
    required this.enabled,
    required this.autoStop,
    this.duration,
  });

  final bool enabled;
  final bool autoStop;
  final Duration? duration;
}
