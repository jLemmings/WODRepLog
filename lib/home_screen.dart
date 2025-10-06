import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'build_config.dart';
import 'timer_view.dart';
import 'video_recorder.dart';

class HomeScreen extends StatefulWidget {
  final CameraDescription camera;

  const HomeScreen({super.key, required this.camera});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<String> _versionLabel = _loadVersionLabel();

  Future<String> _loadVersionLabel() async {
    final info = await PackageInfo.fromPlatform();
    final buildNumber = info.buildNumber;
    return buildNumber.isNotEmpty ? '${info.version}+$buildNumber' : info.version;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WODRepLog',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VideoRecorder()),
                );
              },
              child: const Text('Go to Video Recorder'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimerView()),
                );
              },
              child: const Text('Go to Timer View'),
            ),
            if (kShowVersionBanner)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: FutureBuilder<String>(
                  future: _versionLabel,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }

                    final theme = Theme.of(context);
                    final outlineColor = theme.colorScheme.outline;
                    final textStyle = theme.textTheme.bodySmall?.copyWith(
                          color: outlineColor,
                        ) ??
                        TextStyle(color: outlineColor, fontSize: 12);

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text('Version unavailable', style: textStyle);
                    }

                    return Text(
                      'Version ${snapshot.data}',
                      style: textStyle,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
