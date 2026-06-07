import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'l10n/app_localizations.dart';
import 'services/app_services.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final cameraService = const CameraService();
  final cameras = await cameraService.availableDeviceCameras();
  final homePreferences = HomePreferencesStore(preferences);

  runApp(
    MyApp(
      camera: cameras.firstOrNull,
      initialAthleteName: homePreferences.athleteName,
      initialLanguageCode: homePreferences.languageCode,
      homePreferences: homePreferences,
      recorderSettingsStore: RecorderSettingsStore(preferences),
      liftStatsStore: LiftStatsStore(preferences),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.camera,
    required this.initialAthleteName,
    required this.initialLanguageCode,
    required this.homePreferences,
    required this.recorderSettingsStore,
    required this.liftStatsStore,
    this.beepService = const NativeBeepService(),
    this.appInfoService = const AppInfoService(),
    this.videoOverlayService = const VideoOverlayService(),
    this.galleryService = const GalleryService(),
  });

  final CameraDescription? camera;
  final String initialAthleteName;
  final String? initialLanguageCode;
  final HomePreferencesStore homePreferences;
  final RecorderSettingsStore recorderSettingsStore;
  final LiftStatsStore liftStatsStore;
  final NativeBeepService beepService;
  final AppInfoService appInfoService;
  final VideoOverlayService videoOverlayService;
  final GalleryService galleryService;

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
    await widget.homePreferences.save(
      athleteName: settings.athleteName,
      languageCode: settings.languageCode,
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
        recorderSettingsStore: widget.recorderSettingsStore,
        liftStatsStore: widget.liftStatsStore,
        beepService: widget.beepService,
        appInfoService: widget.appInfoService,
        videoOverlayService: widget.videoOverlayService,
        galleryService: widget.galleryService,
      ),
    );
  }
}
