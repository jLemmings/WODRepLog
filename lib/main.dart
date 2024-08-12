import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';

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
        // Primary color scheme
        primaryColor: const Color(0xFF1C1C1E), // Dark Charcoal
        scaffoldBackgroundColor: const Color(0xFFEFEFF4), // Soft White

        // Color scheme with secondary and tertiary colors
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          accentColor: const Color(0xFF007AFF), // Electric Blue
        ).copyWith(
          secondary: const Color(0xFF32FF7E), // Neon Green
          tertiary: const Color(0xFFFF9500), // Fiery Orange
          error: const Color(0xFFFF3B30), // Crimson Red
          primary: const Color(0xFF1C1C1E), // Dark Charcoal
        ),

        // Text theme
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF8E8E93)), // Cool Gray
          bodyMedium: TextStyle(color: Color(0xFF1C1C1E)), // Dark Charcoal
        ),

        // Button styling
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF007AFF), // Electric Blue for buttons
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      // Start with the SplashScreen
      home: SplashScreen(camera: camera),
    );
  }
}
