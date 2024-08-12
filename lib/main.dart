import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import the SplashScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Recorder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Start with the SplashScreen
      home: SplashScreen(camera: camera),
    );
  }
}
