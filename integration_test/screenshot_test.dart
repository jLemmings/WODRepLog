import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;

import 'package:wodreplog/main.dart';

const _screenshotDirectory = String.fromEnvironment(
  'SCREENSHOT_DIR',
  defaultValue: 'integration_test/screenshots',
);

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    final directory = Directory(_screenshotDirectory);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    for (final entity in directory.listSync()) {
      if (entity is File && entity.path.toLowerCase().endsWith('.png')) {
        entity.deleteSync();
      }
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

    await _captureScreenshot(tester, binding, '01_splash_screen');

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    await _captureScreenshot(tester, binding, '02_home_screen');

    final timerButton = find.text('Go to Timer View');
    expect(timerButton, findsOneWidget);
    await tester.tap(timerButton);
    await tester.pumpAndSettle();

    await _captureScreenshot(tester, binding, '03_timer_view');

    final amrapButton = find.text('AMRAP');
    if (amrapButton.evaluate().isNotEmpty) {
      await tester.tap(amrapButton);
      await tester.pumpAndSettle();
      await _captureScreenshot(tester, binding, '04_amrap_settings');
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await tester.pageBack();
    await tester.pumpAndSettle();

    await _captureScreenshot(tester, binding, '05_home_after_timer');
  });
}

Future<void> _captureScreenshot(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding,
  String name,
) async {
  final directory = Directory(_screenshotDirectory);
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  await tester.runAsync(() async {
    final ui.Image image = await binding.renderView.toImage(
      pixelRatio:
          binding.platformDispatcher.implicitView?.devicePixelRatio ?? 1.0,
    );
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return;
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();
    final file = File(p.join(directory.path, '$name.png'));
    await file.writeAsBytes(pngBytes, flush: true);
  });
}
