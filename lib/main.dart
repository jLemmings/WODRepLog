import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'theme.dart'; // Import the theme file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CameraDescription? selectedCamera;
  try {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      selectedCamera = cameras.first;
    }
  } on CameraException catch (error, stackTrace) {
    debugPrint('Unable to load camera hardware: $error');
    debugPrintStack(stackTrace: stackTrace);
  } catch (error, stackTrace) {
    debugPrint('Unexpected error while loading cameras: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(MyApp(camera: selectedCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription? camera;

  const MyApp({super.key, this.camera});

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
