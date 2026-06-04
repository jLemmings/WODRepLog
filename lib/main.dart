import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'l10n/app_localizations.dart';
import 'theme.dart';

const _athleteNamePreferenceKey = 'athleteName';
const _languageCodePreferenceKey = 'languageCode';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MyApp(
      camera: firstCamera,
      initialAthleteName:
          preferences.getString(_athleteNamePreferenceKey) ?? '',
      initialLanguageCode: preferences.getString(_languageCodePreferenceKey),
      preferences: preferences,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.camera,
    required this.initialAthleteName,
    required this.initialLanguageCode,
    required this.preferences,
  });

  final CameraDescription camera;
  final String initialAthleteName;
  final String? initialLanguageCode;
  final SharedPreferences preferences;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _athleteName;
  String? _languageCode;

  @override
  void initState() {
    super.initState();
    _athleteName = widget.initialAthleteName;
    _languageCode = widget.initialLanguageCode;
  }

  Future<void> _updateHomeSettings(HomeSettings settings) async {
    await widget.preferences.setString(
      _athleteNamePreferenceKey,
      settings.athleteName,
    );
    await widget.preferences.setString(
      _languageCodePreferenceKey,
      settings.languageCode,
    );

    setState(() {
      _athleteName = settings.athleteName;
      _languageCode = settings.languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: _languageCode == null ? null : Locale(_languageCode!),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: HomeScreen(
        camera: widget.camera,
        athleteName: _athleteName,
        languageCode: _languageCode,
        onSettingsChanged: _updateHomeSettings,
      ),
    );
  }
}
