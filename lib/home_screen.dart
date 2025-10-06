import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'timer_view.dart';
import 'video_recorder.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.camera,
    this.cameraError,
  });

  final CameraDescription? camera;
  final String? cameraError;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (cameraError != null) ...[
                Text(
                  cameraError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: camera == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoRecorder(
                                camera: camera!,
                              ),
                            ),
                          );
                        },
                  child: const Text('Go to Video Recorder'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TimerView(),
                      ),
                    );
                  },
                  child: const Text('Go to Timer View'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
