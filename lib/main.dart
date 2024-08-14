import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'theme.dart'; // Import the theme file

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
      theme: AppTheme.lightTheme, // Light theme (optional)
      darkTheme: AppTheme.darkTheme, // Dark theme
      themeMode: ThemeMode.dark, // Set dark theme by default
      home: SplashScreen(camera: camera), // Start with the SplashScreen
    );
  }
}
