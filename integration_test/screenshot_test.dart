import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:wodreplog/main.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;

  const outputDirectory = 'integration_test/screenshots';
  binding.testOutputsDirectory = outputDirectory;

  setUpAll(() {
    final directory = Directory(outputDirectory);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  });

  testWidgets('captures screenshots of primary flows', (tester) async {
    const fakeCamera = CameraDescription(
      name: 'Test Camera',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 0,
    );

    await tester.pumpWidget(const MyApp(camera: fakeCamera));
    await tester.pump();

    await binding.takeScreenshot('01_splash_screen');

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await binding.takeScreenshot('02_home_screen');

    final timerButton = find.text('Go to Timer View');
    expect(timerButton, findsOneWidget);
    await tester.tap(timerButton);
    await tester.pumpAndSettle();

    await binding.takeScreenshot('03_timer_view');

    final amrapButton = find.text('AMRAP');
    if (amrapButton.evaluate().isNotEmpty) {
      await tester.tap(amrapButton);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('04_amrap_settings');
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await tester.pageBack();
    await tester.pumpAndSettle();

    await binding.takeScreenshot('05_home_after_timer');
  });
}
