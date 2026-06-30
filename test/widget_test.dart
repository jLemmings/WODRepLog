import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wodreplog/main.dart';
import 'package:wodreplog/services/app_services.dart';

void main() {
  testWidgets('renders timer first and switches to log', (
    WidgetTester tester,
  ) async {
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
        liftStatsStore: LiftStatsStore(preferences),
      ),
    );

    expect(find.text('Choose format'), findsOneWidget);
    expect(find.text('TIMER'), findsOneWidget);

    await tester.tap(find.text('STATS'));
    await tester.pumpAndSettle();

    expect(find.text('Lift progress'), findsOneWidget);
    expect(find.text('No lifts recorded yet'), findsOneWidget);

    await tester.tap(find.text('LOG'));
    await tester.pumpAndSettle();

    expect(find.text('Record Proof'), findsOneWidget);
    expect(find.text('Recording Details'), findsOneWidget);
    expect(find.text('Recording'), findsOneWidget);
  });

  testWidgets('filters lift progress by search text', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'liftStatsEntries': jsonEncode([
        {
          'id': '1',
          'liftName': 'Back Squat',
          'weight': 100,
          'reps': 5,
          'performedAt': '2026-01-01T10:00:00.000',
        },
        {
          'id': '2',
          'liftName': 'Deadlift',
          'weight': 150,
          'reps': 3,
          'performedAt': '2026-01-02T10:00:00.000',
        },
        {
          'id': '3',
          'liftName': 'Strict Press',
          'weight': 50,
          'reps': 5,
          'performedAt': '2026-01-03T10:00:00.000',
        },
      ]),
    });
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
        liftStatsStore: LiftStatsStore(preferences),
      ),
    );

    await tester.tap(find.text('STATS'));
    await tester.pumpAndSettle();

    expect(find.text('Back Squat'), findsOneWidget);
    expect(find.text('Deadlift'), findsOneWidget);
    expect(find.text('Strict Press'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('lift-search-field')),
      'dead',
    );
    await tester.pumpAndSettle();

    expect(find.text('Back Squat'), findsNothing);
    expect(find.text('Deadlift'), findsOneWidget);
    expect(find.text('Strict Press'), findsNothing);
  });
}
