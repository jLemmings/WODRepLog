import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart' as path;

class VideoRecorder extends StatefulWidget {
  const VideoRecorder({super.key});

  @override
  _VideoRecorderState createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder> {
  CameraController? _controller;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.high);
    await _controller!.initialize();
    setState(() {});
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        !_isRecording) {
      return;
    }

    try {
      // Stop recording and get the video file
      final XFile videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });

      final filePath = videoFile.path;
      final file = File(filePath);

      // Check if the file exists
      if (!await file.exists()) {
        print('File does not exist at path: $filePath');
        return;
      }

      // Check and validate the file type

      final newFilePath = '${path.withoutExtension(filePath)}.mp4';
      await file.rename(newFilePath);

      print('debug: $file');
      // Save video to gallery
      final bool? success = await GallerySaver.saveVideo(newFilePath);
      if (success == true) {
        print('Video saved to gallery');
      } else {
        print('Failed to save video to gallery');
      }
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Recorder')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Video Recorder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
