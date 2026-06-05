import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_services.dart';
import '../timer_screen.dart';
import '../theme.dart';
import 'timer_picker_sheet.dart';
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
    final intervalLabel = _formatTime(_minutes, _seconds);
    final totalLabel = _formatTime(_totalTime ~/ 60, _totalTime % 60);

    return TimerSettingsLayout(
      accentColor: accentColor,
      title: l10n.emomTitle,
      subtitle: l10n.emomDescription,
      icon: Icons.schedule,
      content: [
        TimerSettingsTile(
          accentColor: accentColor,
          label: l10n.rounds,
          value: '$_rounds',
          helper: l10n.roundsHelper,
          icon: Icons.repeat,
          onTap: () {
            showTimerNumberPicker(
              context: context,
              items: List<int>.generate(100, (index) => index + 1),
              initialValue: _rounds,
              onSelectedItemChanged: (value) {
                setState(() => _rounds = value);
              },
              accentColor: accentColor,
            );
          },
        ),
        TimerSettingsTile(
          accentColor: accentColor,
          label: l10n.intervalLength,
          value: intervalLabel,
          helper: l10n.intervalLengthHelper,
          icon: Icons.timelapse,
          onTap: () {
            showTimerTimePicker(
              context: context,
              accentColor: accentColor,
              initialMinutes: _minutes,
              initialSeconds: _seconds,
              onMinutesChanged: (value) {
                setState(() => _minutes = value);
              },
              onSecondsChanged: (value) {
                setState(() => _seconds = value);
              },
            );
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
