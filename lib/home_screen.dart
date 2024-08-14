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
      appBar: AppBar(
        // Centering the app icon in the AppBar
        title: Center(
          child: Image.asset(
            'assets/icon/app_icon.png', // Replace with your icon's path
            width: 100, // Set the desired width for the icon
            height: 100, // Set the desired height for the icon
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0, // Removes shadow under AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VideoRecorder()),
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
