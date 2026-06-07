import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_services.dart';
import '../timer_screen.dart';
import '../theme.dart';
import 'timer_settings_layout.dart';

class TabataSettings extends StatefulWidget {
  const TabataSettings({super.key, required this.beepService});

  final NativeBeepService beepService;

  @override
  TabataSettingsState createState() => TabataSettingsState();
}

class TabataSettingsState extends State<TabataSettings> {
  int _rounds = 6;
  int _workMinutes = 3;
  int _workSeconds = 0;
  int _restMinutes = 2;
  int _restSeconds = 0;

  int get _workInterval => (_workMinutes * 60) + _workSeconds;
  int get _restInterval => (_restMinutes * 60) + _restSeconds;
  int get _totalTime =>
      (_rounds * (_workInterval + _restInterval)) - _restInterval;

  String _formatTime(int minutes, int seconds) {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.tabataColor;
    final l10n = AppLocalizations.of(context);
    final totalLabel = _formatTime(_totalTime ~/ 60, _totalTime % 60);

    return TimerSettingsLayout(
      accentColor: accentColor,
      title: l10n.tabataTitle,
      subtitle: l10n.tabataDescription,
      icon: Icons.autorenew_rounded,
      content: [
        TimerNumberStepperCard(
          accentColor: accentColor,
          label: l10n.rounds,
          value: _rounds,
          helper: l10n.tabataRoundsHelper,
          maxValue: 30,
          onChanged: (value) {
            setState(() => _rounds = value);
          },
        ),
        TimerTimeStepperCard(
          accentColor: accentColor,
          label: l10n.workInterval,
          helper: l10n.workIntervalHelper,
          minutes: _workMinutes,
          seconds: _workSeconds,
          onMinutesChanged: (value) {
            setState(() => _workMinutes = value);
          },
          onSecondsChanged: (value) {
            setState(() => _workSeconds = value);
          },
        ),
        TimerTimeStepperCard(
          accentColor: accentColor,
          label: l10n.restInterval,
          helper: l10n.restIntervalHelper,
          minutes: _restMinutes,
          seconds: _restSeconds,
          onMinutesChanged: (value) {
            setState(() => _restMinutes = value);
          },
          onSecondsChanged: (value) {
            setState(() => _restSeconds = value);
          },
        ),
      ],
      workoutDuration: totalLabel,
      primaryLabel: l10n.startTimer,
      onPrimaryPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimerScreen(
              duration: _workInterval,
              workoutName: l10n.tabataTitle,
              accentColor: accentColor,
              beepService: widget.beepService,
              interval: _restInterval,
              rounds: _rounds,
              totalDuration: _totalTime,
            ),
          ),
        );
      },
    );
  }
}
