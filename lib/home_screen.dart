import 'package:flutter/material.dart';
import 'video_recorder.dart';
import 'timer_view.dart';
import 'package:camera/camera.dart';

class HomeScreen extends StatelessWidget {
  final CameraDescription? camera;

  const HomeScreen({super.key, this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WODRepLog',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: camera == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoRecorder(camera: camera!),
                        ),
                      );
                    },
              child: Text(
                camera == null
                    ? 'Camera unavailable'
                    : 'Go to Video Recorder',
              ),
            ),
            if (camera == null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'Video recording requires a supported camera.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
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
