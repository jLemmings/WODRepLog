import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_services.dart';
import '../timer_screen.dart';
import '../theme.dart';
import 'timer_settings_layout.dart';

class EmomSettings extends StatefulWidget {
  const EmomSettings({super.key, required this.beepService});

  final NativeBeepService beepService;

  @override
  EmomSettingsState createState() => EmomSettingsState();
}

class EmomSettingsState extends State<EmomSettings> {
  int _minutes = 2;
  int _seconds = 0;
  int _rounds = 12;

  int get _totalInterval => (_minutes * 60) + _seconds;
  int get _totalTime => _totalInterval * _rounds;

  String _formatTime(int minutes, int seconds) {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.emomColor;
    final l10n = AppLocalizations.of(context);
    final totalLabel = _formatTime(_totalTime ~/ 60, _totalTime % 60);

    return TimerSettingsLayout(
      accentColor: accentColor,
      title: l10n.emomTitle,
      subtitle: l10n.emomDescription,
      icon: Icons.timer_rounded,
      content: [
        TimerNumberStepperCard(
          accentColor: accentColor,
          label: l10n.rounds,
          value: _rounds,
          helper: l10n.roundsHelper,
          maxValue: 100,
          onChanged: (value) {
            setState(() => _rounds = value);
          },
        ),
        TimerTimeStepperCard(
          accentColor: accentColor,
          label: l10n.intervalLength,
          helper: l10n.intervalLengthHelper,
          minutes: _minutes,
          seconds: _seconds,
          onMinutesChanged: (value) {
            setState(() => _minutes = value);
          },
          onSecondsChanged: (value) {
            setState(() => _seconds = value);
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
              duration: _totalInterval,
              workoutName: l10n.emomTitle,
              accentColor: accentColor,
              beepService: widget.beepService,
              rounds: _rounds,
              totalDuration: _totalTime,
            ),
          ),
        );
      },
    );
  }
}
