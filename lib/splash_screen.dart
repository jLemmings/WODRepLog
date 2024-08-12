import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';
import 'package:camera/camera.dart';

class SplashScreen extends StatefulWidget {
  final CameraDescription camera;

  const SplashScreen({super.key, required this.camera});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to HomeScreen after 5 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(camera: widget.camera),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
