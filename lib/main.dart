import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'splash_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CameraDescription? camera;
  String? cameraError;

  try {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      camera = cameras.first;
    } else {
      cameraError = 'No cameras available on this device.';
    }
  } on CameraException catch (error) {
    cameraError = error.description ?? error.code;
  } catch (error) {
    cameraError = error.toString();
  }

  runApp(MyApp(
    camera: camera,
    cameraError: cameraError,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.camera,
    this.cameraError,
  });

  final CameraDescription? camera;
  final String? cameraError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WODRepLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: SplashScreen(
        camera: camera,
        cameraError: cameraError,
      ),
    );
  }
}
