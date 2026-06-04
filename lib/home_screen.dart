import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n/app_localizations.dart';
import 'timer_view.dart';
import 'video_recorder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.camera,
    required this.athleteName,
    required this.languageCode,
    required this.onSettingsChanged,
  });

  final CameraDescription camera;
  final String athleteName;
  final String? languageCode;
  final ValueChanged<HomeSettings> onSettingsChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class HomeSettings {
  const HomeSettings({required this.athleteName, required this.languageCode});

  final String athleteName;
  final String languageCode;
}

class _HomeScreenState extends State<HomeScreen> {
  static const MethodChannel _appInfoChannel = MethodChannel(
    'ch.joshuahemmings.wodreplog/app_info',
  );
  static const String _buildName = String.fromEnvironment(
    'FLUTTER_BUILD_NAME',
    defaultValue: 'unknown',
  );
  static const String _buildNumber = String.fromEnvironment(
    'FLUTTER_BUILD_NUMBER',
    defaultValue: '',
  );

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

  Future<void> _openSettingsSheet() async {
    final currentLanguageCode =
        widget.languageCode ?? Localizations.localeOf(context).languageCode;
    final supportedLanguageCode =
        AppLocalizations.supportedLocales.any(
          (locale) => locale.languageCode == currentLanguageCode,
        )
        ? currentLanguageCode
        : 'en';

    final result = await showModalBottomSheet<HomeSettings>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _HomeSettingsSheet(
        athleteName: widget.athleteName,
        languageCode: supportedLanguageCode,
      ),
    );

    if (result != null) {
      widget.onSettingsChanged(result);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.homeQuestion,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Tooltip(
                      message: l10n.settings,
                      child: IconButton.filledTonal(
                        onPressed: _openSettingsSheet,
                        icon: const Icon(Icons.settings_rounded),
                      ),
                    ),
                  ],
                ),
                if (widget.athleteName.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.athleteGreeting(widget.athleteName.trim()),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
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
        builder: (context) =>
            VideoRecorder(initialAthleteName: widget.athleteName),
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

class _HomeSettingsSheet extends StatefulWidget {
  const _HomeSettingsSheet({
    required this.athleteName,
    required this.languageCode,
  });

  final String athleteName;
  final String languageCode;

  @override
  State<_HomeSettingsSheet> createState() => _HomeSettingsSheetState();
}

class _HomeSettingsSheetState extends State<_HomeSettingsSheet> {
  late final TextEditingController _athleteController;
  late String _languageCode;

  @override
  void initState() {
    super.initState();
    _athleteController = TextEditingController(text: widget.athleteName);
    _languageCode = widget.languageCode;
  }

  @override
  void dispose() {
    _athleteController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      HomeSettings(
        athleteName: _athleteController.text.trim(),
        languageCode: _languageCode,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.transparent),
    );
    return InputDecoration(
      hintText: hint,
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 1.4),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.settings,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.athleteName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _athleteController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(l10n.athleteNameHint),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.preferredLanguage,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _languageCode,
                    isExpanded: true,
                    decoration: _inputDecoration(l10n.selectLanguage),
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(l10n.englishLanguage),
                      ),
                      DropdownMenuItem(
                        value: 'de',
                        child: Text(l10n.germanLanguage),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _languageCode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: Text(l10n.saveSettings),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: Text(l10n.cancel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: option.builder)),
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
