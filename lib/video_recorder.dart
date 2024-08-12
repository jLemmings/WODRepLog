import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:gallery_saver/gallery_saver.dart';

class VideoRecorder extends StatefulWidget {
  const VideoRecorder({super.key});

  @override
  _VideoRecorderState createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder> {
  late CameraController _controller;
  bool _isRecording = false;
  bool _showTimer = false;
  String competitionName = '';
  String workoutName = '';
  Timer? _timer;
  int _elapsedSeconds = 0;

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
    _controller.dispose();
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

  void _startTimer() {
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _startRecording() async {
    if (!_controller.value.isInitialized) return;

    try {
      await _controller.startVideoRecording();
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
    if (!_controller.value.isInitialized || !_isRecording) return;

    try {
      final XFile videoFile = await _controller.stopVideoRecording();
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

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Center(
            // Center the FittedBox horizontally
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.previewSize!.width,
                height: _controller.value.previewSize!.height,
                child: CameraPreview(_controller),
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
          if (_isRecording &&
              _showTimer) // Show the timer only when recording and if it's enabled
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
            left: MediaQuery.of(context).size.width / 2 -
                28, // Center the record button
            child: FloatingActionButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Icon(_isRecording ? Icons.stop : Icons.videocam),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showTimer = !_showTimer;
                });
              },
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
