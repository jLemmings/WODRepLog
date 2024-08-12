import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wodreplog/main.dart'; // Import your MyApp class from the appropriate file
import 'package:camera/camera.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Set up a mock CameraDescription
    const camera = CameraDescription(
      name: 'Test Camera',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 0,
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(camera: camera)); // Pass the camera parameter

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
