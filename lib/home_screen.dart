import 'package:flutter/material.dart';
import 'video_recorder.dart';
import 'timer_view.dart';
import 'package:camera/camera.dart';

class HomeScreen extends StatelessWidget {
  final CameraDescription camera;

  const HomeScreen({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VideoRecorder()),
                );
              },
              child: const Text('Go to Video Recorder'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimerView()),
                );
              },
              child: const Text('Go to Timer View'),
            ),
          ],
        ),
      ),
    );
  }
}
