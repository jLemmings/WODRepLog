import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wodreplog/main.dart';
import 'package:wodreplog/services/app_services.dart';

void main() {
  testWidgets('renders home screen actions', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const camera = CameraDescription(
      name: 'Test Camera',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 0,
    );

    await tester.pumpWidget(
      MyApp(
        camera: camera,
        initialAthleteName: '',
        initialLanguageCode: 'en',
        homePreferences: HomePreferencesStore(preferences),
        recorderSettingsStore: RecorderSettingsStore(preferences),
      ),
    );

    expect(find.text('Record Proof'), findsOneWidget);
    expect(find.text('Workout Timer'), findsOneWidget);
  });
}
