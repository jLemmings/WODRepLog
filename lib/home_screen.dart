import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n/app_localizations.dart';
import 'timer_view.dart';
import 'video_recorder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const MethodChannel _appInfoChannel = MethodChannel(
    'ch.joshuahemmings.wodreplog/app_info',
  );
  static const String _buildName =
      String.fromEnvironment('FLUTTER_BUILD_NAME', defaultValue: 'unknown');
  static const String _buildNumber =
      String.fromEnvironment('FLUTTER_BUILD_NUMBER', defaultValue: '');

  String? _nativeVersionName;

  String get _versionLabel =>
      _nativeVersionName ??
      (_buildNumber.isNotEmpty ? '$_buildName+$_buildNumber' : _buildName);

  @override
  void initState() {
    super.initState();
    _loadNativeVersionName();
  }

  Future<void> _loadNativeVersionName() async {
    try {
      final versionName = await _appInfoChannel.invokeMethod<String>(
        'getVersionName',
      );
      if (!mounted || versionName == null || versionName.isEmpty) return;
      setState(() {
        _nativeVersionName = versionName;
      });
    } on PlatformException {
      // Keep the compile-time fallback for platforms without this channel.
    } on MissingPluginException {
      // Keep the compile-time fallback for platforms without this channel.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final options = _homeOptions(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101318), Color(0xFF171B22)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.appTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.appDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.62),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.homeQuestion,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.homeSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.68),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: options.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _ActionPanel(option: options[index]);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.versionLabel(_versionLabel),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.42),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_HomeOption> _homeOptions(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return [
      _HomeOption(
        title: l10n.recordProofTitle,
        subtitle: l10n.recordProofSubtitle,
        eyebrow: l10n.cameraEyebrow,
        icon: Icons.videocam_rounded,
        color: scheme.primary,
        builder: (context) => const VideoRecorder(),
      ),
      _HomeOption(
        title: l10n.workoutTimerTitle,
        subtitle: l10n.workoutTimerSubtitle,
        eyebrow: l10n.timerEyebrow,
        icon: Icons.timer_rounded,
        color: scheme.secondary,
        builder: (context) => const TimerView(),
      ),
    ];
  }
}

class _HomeOption {
  const _HomeOption({
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.icon,
    required this.color,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final String eyebrow;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.option});

  final _HomeOption option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: option.builder),
        ),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1D222B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: option.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(option.icon, color: option.color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.eyebrow.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: option.color,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      option.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.62),
                        height: 1.28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
