import 'dart:io';
import 'package:flutter/material.dart';
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
  String competitionName = '';
  String workoutName = '';

  final List<Map<String, dynamic>> _textFields = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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

  void _addTextField() {
    setState(() {
      _textFields.add({
        'text': '',
        'top': 100.0,
        'left': 100.0,
      });
    });
  }

  void _updateTextField(int index, String text) {
    setState(() {
      _textFields[index]['text'] = text;
    });
  }

  void _updatePosition(int index, Offset position) {
    setState(() {
      _textFields[index]['top'] = position.dy;
      _textFields[index]['left'] = position.dx;
    });
  }

  Future<void> _startRecording() async {
    if (!_controller.value.isInitialized) return;

    try {
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Recorder')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Video Recorder')),
      body: Stack(
        children: [
          CameraPreview(_controller),
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
            top: 60,
            left: 20,
            child: Text(
              workoutName,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          ..._textFields.map((textField) {
            int index = _textFields.indexOf(textField);
            return Positioned(
              top: textField['top'],
              left: textField['left'],
              child: GestureDetector(
                onPanUpdate: (details) {
                  _updatePosition(index, details.localPosition);
                },
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter text',
                    ),
                    onChanged: (text) {
                      _updateTextField(index, text);
                    },
                    controller: TextEditingController(text: textField['text']),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showInputDialog,
            child: const Icon(Icons.text_fields),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _addTextField,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
