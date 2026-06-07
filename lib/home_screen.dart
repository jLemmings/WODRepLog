import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'app_footer.dart';
import 'app_header.dart';
import 'domain/recorder_settings.dart';
import 'domain/workout_timer.dart';
import 'l10n/app_localizations.dart';
import 'services/app_services.dart';
import 'stats_view.dart';
import 'timer_view.dart';
import 'video_recorder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.camera,
    required this.athleteName,
    required this.languageCode,
    required this.onSettingsChanged,
    required this.recorderSettingsStore,
    required this.liftStatsStore,
    required this.beepService,
    required this.appInfoService,
    required this.videoOverlayService,
    required this.galleryService,
  });

  final CameraDescription? camera;
  final String athleteName;
  final String? languageCode;
  final ValueChanged<HomeSettings> onSettingsChanged;
  final RecorderSettingsStore recorderSettingsStore;
  final LiftStatsStore liftStatsStore;
  final NativeBeepService beepService;
  final AppInfoService appInfoService;
  final VideoOverlayService videoOverlayService;
  final GalleryService galleryService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class HomeSettings {
  const HomeSettings({required this.athleteName, required this.languageCode});

  final String athleteName;
  final String languageCode;
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _buildName = String.fromEnvironment(
    'FLUTTER_BUILD_NAME',
    defaultValue: 'unknown',
  );
  static const String _buildNumber = String.fromEnvironment(
    'FLUTTER_BUILD_NUMBER',
    defaultValue: '',
  );

  String? _nativeVersionName;
  late final TextEditingController _athleteController;
  late final TextEditingController _eventController;
  late final TextEditingController _workoutController;
  late final TextEditingController _durationController;
  late final TextEditingController _intervalController;
  late final TextEditingController _roundsController;
  late final TextEditingController _countdownController;
  final _recorderFormKey = GlobalKey<FormState>();
  TimerTypeOption _selectedTimerType = TimerTypeOption.none;
  AppFooterItem _activeItem = AppFooterItem.timer;

  String get _versionLabel =>
      _nativeVersionName ??
      (_buildNumber.isNotEmpty ? '$_buildName+$_buildNumber' : _buildName);

  @override
  void initState() {
    super.initState();
    _athleteController = TextEditingController();
    _eventController = TextEditingController();
    _workoutController = TextEditingController();
    _durationController = TextEditingController();
    _intervalController = TextEditingController();
    _roundsController = TextEditingController();
    _countdownController = TextEditingController();
    _loadRecorderSettings();
    _loadNativeVersionName();
  }

  @override
  void dispose() {
    _athleteController.dispose();
    _eventController.dispose();
    _workoutController.dispose();
    _durationController.dispose();
    _intervalController.dispose();
    _roundsController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  Future<void> _loadNativeVersionName() async {
    final versionName = await widget.appInfoService.versionName();
    if (!mounted || versionName == null || versionName.isEmpty) return;
    setState(() {
      _nativeVersionName = versionName;
    });
  }

  void _loadRecorderSettings() {
    final settings = widget.recorderSettingsStore.load(
      fallbackAthleteName: widget.athleteName.trim(),
    );
    _athleteController.text = settings.athleteName;
    _eventController.text = settings.eventName;
    _workoutController.text = settings.workoutTitle;
    _countdownController.text = settings.countdownSeconds.toString();
    _applyTimerConfiguration(settings.timerConfiguration);
  }

  void _applyTimerConfiguration(TimerConfiguration? timer) {
    _durationController.clear();
    _intervalController.clear();
    _roundsController.clear();
    _selectedTimerType = TimerTypeOption.none;

    if (timer == null) return;
    switch (timer.type) {
      case WorkoutTimerType.amrap:
        _selectedTimerType = TimerTypeOption.amrap;
        _durationController.text = _secondsToMinutes(timer.totalSeconds);
        break;
      case WorkoutTimerType.forTime:
        _selectedTimerType = TimerTypeOption.forTime;
        _durationController.text = _secondsToMinutes(timer.totalSeconds);
        break;
      case WorkoutTimerType.emom:
        _selectedTimerType = TimerTypeOption.emom;
        _intervalController.text = (timer.intervalSeconds ?? 60).toString();
        _roundsController.text = (timer.rounds ?? 10).toString();
        break;
      case WorkoutTimerType.tabata:
        _selectedTimerType = TimerTypeOption.none;
        break;
    }
  }

  Future<void> _startRecordingFlow() async {
    final settings = _recorderSettingsFromForm();
    if (settings == null) return;
    await widget.recorderSettingsStore.save(settings);
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoRecorder(
          camera: widget.camera,
          initialAthleteName: settings.athleteName.trim().isNotEmpty
              ? settings.athleteName
              : widget.athleteName,
          settingsStore: widget.recorderSettingsStore,
          beepService: widget.beepService,
          videoOverlayService: widget.videoOverlayService,
          galleryService: widget.galleryService,
        ),
      ),
    );
  }

  RecorderSettings? _recorderSettingsFromForm() {
    if (!(_recorderFormKey.currentState?.validate() ?? false)) {
      return null;
    }

    TimerConfiguration? timerConfig;
    switch (_selectedTimerType) {
      case TimerTypeOption.none:
        timerConfig = null;
        break;
      case TimerTypeOption.amrap:
        timerConfig = TimerConfiguration(
          type: WorkoutTimerType.amrap,
          totalSeconds: _minutesFieldToSeconds(_durationController.text),
        );
        break;
      case TimerTypeOption.forTime:
        timerConfig = TimerConfiguration(
          type: WorkoutTimerType.forTime,
          totalSeconds: _minutesFieldToSeconds(_durationController.text),
        );
        break;
      case TimerTypeOption.emom:
        timerConfig = TimerConfiguration(
          type: WorkoutTimerType.emom,
          intervalSeconds: int.parse(_intervalController.text),
          rounds: int.parse(_roundsController.text),
        );
        break;
    }

    return RecorderSettings(
      athleteName: _athleteController.text.trim(),
      eventName: _eventController.text.trim(),
      workoutTitle: _workoutController.text.trim(),
      countdownSeconds: int.parse(_countdownController.text),
      timerConfiguration: timerConfig,
    );
  }

  String _secondsToMinutes(int? seconds) {
    if (seconds == null || seconds <= 0) return '';
    final minutes = seconds / 60;
    if (minutes % 1 == 0) {
      return minutes.toInt().toString();
    }
    return minutes.toStringAsFixed(1);
  }

  int _minutesFieldToSeconds(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.')) ?? 0;
    return (parsed * 60).round();
  }

  InputDecoration _recorderInputDecoration(String hint) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.transparent),
    );
    return InputDecoration(
      hintText: hint.isEmpty ? null : hint,
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFF347FFF), width: 1.4),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  BoxDecoration _recorderPanelDecoration() {
    return BoxDecoration(
      color: const Color(0xFF182A3E),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    );
  }

  void _openTimer() {
    setState(() {
      _activeItem = AppFooterItem.timer;
    });
  }

  void _openLog() {
    setState(() {
      _activeItem = AppFooterItem.log;
    });
  }

  void _openStats() {
    setState(() {
      _activeItem = AppFooterItem.stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activeItem == AppFooterItem.timer) {
      return TimerView(
        beepService: widget.beepService,
        onLogTap: _openLog,
        onStatsTap: _openStats,
      );
    }

    if (_activeItem == AppFooterItem.stats) {
      return StatsView(
        statsStore: widget.liftStatsStore,
        onLogTap: _openLog,
        onTimerTap: _openTimer,
      );
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: const AppHeader(),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E1520), Color(0xFF122238)],
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
                        l10n.recordProofTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Form(
                    key: _recorderFormKey,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Text(
                          l10n.recordProofSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.68),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildOverlayDetailsCard(context),
                        const SizedBox(height: 16),
                        _buildTimerOverlayCard(context),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: FilledButton.icon(
                    onPressed: _startRecordingFlow,
                    icon: const Icon(Icons.videocam_rounded),
                    label: const Text('Recording'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
      bottomNavigationBar: AppFooter(
        activeItem: AppFooterItem.log,
        onTimerTap: _openTimer,
        onStatsTap: _openStats,
      ),
    );
  }

  Widget _buildOverlayDetailsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _recorderPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InlineSectionTitle(
            icon: Icons.badge_rounded,
            title: l10n.recordingDetails,
          ),
          const SizedBox(height: 16),
          _FormFieldLabel(text: l10n.athleteName),
          const SizedBox(height: 8),
          TextFormField(
            controller: _athleteController,
            textCapitalization: TextCapitalization.words,
            decoration: _recorderInputDecoration(l10n.athleteNameHint),
          ),
          const SizedBox(height: 14),
          _FormFieldLabel(text: l10n.eventName),
          const SizedBox(height: 8),
          TextFormField(
            controller: _eventController,
            textCapitalization: TextCapitalization.words,
            decoration: _recorderInputDecoration(l10n.eventNameHint),
          ),
          const SizedBox(height: 14),
          _FormFieldLabel(text: l10n.workoutQualifierTitle),
          const SizedBox(height: 8),
          TextFormField(
            controller: _workoutController,
            textCapitalization: TextCapitalization.sentences,
            decoration: _recorderInputDecoration(l10n.workoutTitleHint),
          ),
          const SizedBox(height: 14),
          _FormFieldLabel(
            text: l10n.countdownSeconds,
            caption: l10n.countdownCaption,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _countdownController,
            keyboardType: TextInputType.number,
            decoration: _recorderInputDecoration(l10n.secondsExampleHint),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterCountdownSeconds;
              }
              final parsed = int.tryParse(value);
              if (parsed == null || parsed < 0) {
                return l10n.countdownNonNegative;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimerOverlayCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _recorderPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InlineSectionTitle(
            icon: Icons.timer_rounded,
            title: l10n.timerTitle,
          ),
          const SizedBox(height: 14),
          _FormFieldLabel(text: l10n.timerType, caption: l10n.timerTypeCaption),
          const SizedBox(height: 8),
          DropdownButtonFormField<TimerTypeOption>(
            initialValue: _selectedTimerType,
            isExpanded: true,
            decoration: _recorderInputDecoration(l10n.selectTimerType),
            items: [
              DropdownMenuItem(
                value: TimerTypeOption.none,
                child: Text(l10n.noTimerOverlay),
              ),
              DropdownMenuItem(
                value: TimerTypeOption.emom,
                child: Text(l10n.emomTitle),
              ),
              DropdownMenuItem(
                value: TimerTypeOption.amrap,
                child: Text(l10n.amrapTitle),
              ),
              DropdownMenuItem(
                value: TimerTypeOption.forTime,
                child: Text(l10n.forTimeTitle),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedTimerType = value;
              });
            },
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildTimerFields(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerFields() {
    final l10n = AppLocalizations.of(context);
    switch (_selectedTimerType) {
      case TimerTypeOption.none:
        return Text(
          key: const ValueKey('timer-none'),
          l10n.noTimerOverlayMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.68),
          ),
        );
      case TimerTypeOption.emom:
        return Column(
          key: const ValueKey('timer-emom'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FormFieldLabel(
              text: l10n.intervalLengthSeconds,
              caption: l10n.intervalLengthSecondsHelper,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _intervalController,
              keyboardType: TextInputType.number,
              decoration: _recorderInputDecoration(l10n.secondsExampleHint),
              validator: (value) {
                if (_selectedTimerType != TimerTypeOption.emom) return null;
                if (value == null || value.isEmpty) {
                  return l10n.enterIntervalLength;
                }
                final parsed = int.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return l10n.intervalPositive;
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _FormFieldLabel(text: l10n.rounds, caption: l10n.roundsCaption),
            const SizedBox(height: 8),
            TextFormField(
              controller: _roundsController,
              keyboardType: TextInputType.number,
              decoration: _recorderInputDecoration(l10n.roundsExampleHint),
              validator: (value) {
                if (_selectedTimerType != TimerTypeOption.emom) return null;
                if (value == null || value.isEmpty) {
                  return l10n.enterRounds;
                }
                final parsed = int.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return l10n.roundsPositive;
                }
                return null;
              },
            ),
          ],
        );
      case TimerTypeOption.amrap:
        return _buildDurationMinutesField(
          key: const ValueKey('timer-amrap'),
          label: l10n.durationMinutes,
          helper: l10n.durationMinutesHelper,
        );
      case TimerTypeOption.forTime:
        return _buildDurationMinutesField(
          key: const ValueKey('timer-for-time'),
          label: l10n.timeCapMinutes,
          helper: l10n.timeCapMinutesHelper,
        );
    }
  }

  Widget _buildDurationMinutesField({
    required Key key,
    required String label,
    required String helper,
  }) {
    final l10n = AppLocalizations.of(context);
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FormFieldLabel(text: label, caption: helper),
        const SizedBox(height: 8),
        TextFormField(
          controller: _durationController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _recorderInputDecoration(l10n.minutesExampleHint),
          validator: (value) {
            if (_selectedTimerType != TimerTypeOption.amrap &&
                _selectedTimerType != TimerTypeOption.forTime) {
              return null;
            }
            if (value == null || value.isEmpty) {
              return l10n.enterDurationMinutes;
            }
            final parsed = double.tryParse(value.replaceAll(',', '.'));
            if (parsed == null || parsed <= 0) {
              return l10n.durationPositive;
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _InlineSectionTitle extends StatelessWidget {
  const _InlineSectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _FormFieldLabel extends StatelessWidget {
  const _FormFieldLabel({required this.text, this.caption});

  final String text;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 4),
          Text(
            caption!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}
