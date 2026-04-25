import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'timer_view.dart';
import 'video_recorder.dart';

class HomeScreen extends StatefulWidget {
  final CameraDescription camera;

  const HomeScreen({super.key, required this.camera});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _buildName =
      String.fromEnvironment('FLUTTER_BUILD_NAME', defaultValue: 'unknown');
  static const String _buildNumber =
      String.fromEnvironment('FLUTTER_BUILD_NUMBER', defaultValue: '');

  String get _versionLabel =>
      _buildNumber.isNotEmpty ? '$_buildName+$_buildNumber' : _buildName;

  @override
  Widget build(BuildContext context) {
    final options = _homeOptions(context);
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: const Text(
          'WODRepLog',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            const Color(0xFF1C1C1E),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1F1F23),
              Color(0xFF141418),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Let’s get you ready',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Record your workout or dial in the timer experience.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: ListView.separated(
                    itemCount: options.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return _PrimaryNavigationCard(option: option);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    final color = Colors.white.withValues(alpha: 0.55);
                    final textStyle = theme.textTheme.bodySmall?.copyWith(
                          color: color,
                          letterSpacing: 0.2,
                        ) ??
                        TextStyle(
                          color: color,
                          fontSize: 12,
                        );

                    return Text(
                      'Version $_versionLabel',
                      style: textStyle,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_HomeOption> _homeOptions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      _HomeOption(
        title: 'Video Recorder',
        subtitle: 'Capture workouts with overlays tailored to judges.',
        icon: Icons.videocam_rounded,
        color: colorScheme.primaryContainer.withValues(alpha: 0.9),
        builder: (context) => const VideoRecorder(),
      ),
      _HomeOption(
        title: 'Timer Studio',
        subtitle: 'Build AMRAP, EMOM, For Time, or Tabata sessions.',
        icon: Icons.timer_outlined,
        color: colorScheme.secondaryContainer.withValues(alpha: 0.9),
        builder: (context) => const TimerView(),
      ),
    ];
  }
}

class _HomeOption {
  const _HomeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}

class _PrimaryNavigationCard extends StatelessWidget {
  const _PrimaryNavigationCard({required this.option});

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
        borderRadius: BorderRadius.circular(24),
        splashColor: option.color.withValues(alpha: 0.1),
        highlightColor: option.color.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                option.color.withValues(alpha: 0.36),
                option.color.withValues(alpha: 0.14),
              ],
            ),
            border: Border.all(color: option.color.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: option.color.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(option.icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.75),
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
