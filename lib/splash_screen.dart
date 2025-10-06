import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.camera,
    this.cameraError,
  });

  final CameraDescription? camera;
  final String? cameraError;

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            camera: widget.camera,
            cameraError: widget.cameraError,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use AssetImage to load the image
            Image.asset(
              'assets/icon/app_icon.png', // Replace with your icon's path
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const Text(
              'WODRepLog',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (widget.cameraError != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  widget.cameraError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 14,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
