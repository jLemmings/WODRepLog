import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:gallery_saver_plus/gallery_saver.dart';

import 'utils/time_utils.dart';

class VideoRecorder extends StatefulWidget {
  const VideoRecorder({super.key, this.camera});

  final CameraDescription? camera;

  @override
  VideoRecorderState createState() => VideoRecorderState();
}

class VideoRecorderState extends State<VideoRecorder> {
  CameraController? _controller;
  bool get _hasController =>
      _controller != null && _controller!.value.isInitialized;
  String? _initializationError;
  bool _isRecording = false;
  final bool _showTimer = false;
  String competitionName = '';
  String workoutName = '';
  Timer? _timer;
  int _elapsedSeconds = 0;

  int _timerDuration = 30; // Example duration
  int? _interval;
  int? _rounds;

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    // Force landscape orientation and hide system UI when the camera view is active
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();

    // Reset orientation and show system UI when leaving the camera view
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final camera = await _obtainCamera();
      if (camera == null) {
        setState(() {
          _initializationError = 'No available camera detected.';
        });
        return;
      }

      final controller = CameraController(camera, ResolutionPreset.high);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _initializationError = null;
      });
    } on CameraException catch (e) {
      setState(() {
        _initializationError = 'Failed to initialize camera: ${e.description ?? e.code}';
      });
    } catch (e) {
      setState(() {
        _initializationError = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<CameraDescription?> _obtainCamera() async {
    if (widget.camera != null) {
      return widget.camera;
    }
    try {
      final cameras = await availableCameras();
      return cameras.isNotEmpty ? cameras.first : null;
    } on CameraException {
      return null;
    }
  }

  void _startTimer() {
    if (_interval == null || _rounds == null) return; // Ensure they are set
    _elapsedSeconds = 0;

    _timer = Timer.periodic(Duration(seconds: _interval!), (timer) {
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds >= _rounds! * _timerDuration) {
          _timer?.cancel();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _startRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      _showErrorSnackBar('Camera not ready for recording.');
      return;
    }

    try {
      await controller.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
      if (_showTimer) {
        _startTimer(); // Start the timer when recording starts
      }
    } catch (e) {
      _showErrorSnackBar('Error starting video recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || !_isRecording) {
      return;
    }

    try {
      final XFile videoFile = await controller.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
      _stopTimer(); // Stop the timer when recording stops

      final newFilePath = '${path.withoutExtension(videoFile.path)}.mp4';
      await File(videoFile.path).rename(newFilePath);

      final bool? success = await GallerySaver.saveVideo(newFilePath);
      if (success == true) {
        _showSnackBar('Video saved to gallery');
      } else {
        _showErrorSnackBar('Failed to save video to gallery');
      }
    } catch (e) {
      _showErrorSnackBar('Error stopping video recording: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInputDialog() {
    final competitionController = TextEditingController(text: competitionName);
    final workoutController = TextEditingController(text: workoutName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: competitionController,
                decoration: const InputDecoration(
                  labelText: 'Competition Name',
                ),
              ),
              TextField(
                controller: workoutController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  competitionName = competitionController.text;
                  workoutName = workoutController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showTimerConfigDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Configure Timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Duration (seconds)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _timerDuration = int.parse(value);
                  });
                },
              ),
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Interval (seconds)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _interval = int.parse(value);
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Rounds'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _rounds = int.parse(value);
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) => formatSeconds(seconds);

  @override
  Widget build(BuildContext context) {
    if (!_hasController) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: _initializationError != null
              ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam_off,
                        size: 72,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _initializationError!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeCamera,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      );
    }

    final controller = _controller!;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Transform.rotate(
              angle: 3.14159, // 180 degrees in radians
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.previewSize!.width,
                  height: controller.value.previewSize!.height,
                  child: CameraPreview(controller),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              competitionName,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Text(
              workoutName,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          if (_isRecording && _showTimer)
            Positioned(
              top: 20,
              right: 20,
              child: Text(
                _formatTime(_elapsedSeconds),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: FloatingActionButton(
              onPressed:
                  _isRecording ? _stopRecording : (_hasController ? _startRecording : null),
              child: Icon(_isRecording ? Icons.stop : Icons.videocam),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton(
              onPressed: _showTimerConfigDialog,
              child: const Icon(Icons.timer),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _showInputDialog,
              child: const Icon(Icons.edit),
            ),
          ),
        ],
      ),
    );
  }
}
