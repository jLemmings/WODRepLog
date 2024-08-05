import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class VideoRecorder extends StatefulWidget {
  final CameraDescription camera;

  const VideoRecorder({super.key, required this.camera});

  @override
  _VideoRecorderState createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> _startVideoRecording() async {
    if (!_controller.value.isInitialized) {
      return "Error: Camera is not initialized.";
    }

    final directory = await getApplicationDocumentsDirectory();
    final videoPath = '${directory.path}/${DateTime.now()}.mp4';

    try {
      await _controller.startVideoRecording();
      return videoPath;
    } on CameraException catch (e) {
      print(e);
      return "Error: Could not start video recording.";
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!_controller.value.isRecordingVideo) {
      return;
    }

    try {
      await _controller.stopVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Recorder')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(isRecording ? Icons.stop : Icons.videocam),
        onPressed: () async {
          if (isRecording) {
            await _stopVideoRecording();
            setState(() {
              isRecording = false;
            });
          } else {
            final videoPath = await _startVideoRecording();
            setState(() {
              isRecording = true;
            });
            print('Video recorded to: $videoPath');
          }
        },
      ),
    );
  }
}
