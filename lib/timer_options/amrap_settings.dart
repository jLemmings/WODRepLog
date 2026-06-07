import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_services.dart';
import '../timer_screen.dart';
import '../theme.dart';
import 'timer_settings_layout.dart';

class AmrapSettings extends StatefulWidget {
  const AmrapSettings({super.key, required this.beepService});

  final NativeBeepService beepService;

  @override
  AmrapSettingsState createState() => AmrapSettingsState();
}

class AmrapSettingsState extends State<AmrapSettings> {
  int _minutes = 8;
  int _seconds = 30;

  int get _totalTime => (_minutes * 60) + _seconds;

  String _formatTime(int minutes, int seconds) {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.amrapColor;
    final l10n = AppLocalizations.of(context);
    final durationLabel = _formatTime(_minutes, _seconds);

    return TimerSettingsLayout(
      accentColor: accentColor,
      title: l10n.amrapTitle,
      subtitle: l10n.amrapDescription,
      icon: Icons.change_circle_rounded,
      content: [
        TimerTimeStepperCard(
          accentColor: accentColor,
          label: l10n.duration,
          helper: l10n.durationHelper,
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
      workoutDuration: durationLabel,
      primaryLabel: l10n.startTimer,
      onPrimaryPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimerScreen(
              duration: _totalTime,
              workoutName: l10n.amrapTitle,
              accentColor: accentColor,
              beepService: widget.beepService,
            ),
          ),
        );
      },
    );
  }
}
