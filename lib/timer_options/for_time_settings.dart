import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_services.dart';
import '../timer_screen.dart';
import '../theme.dart';
import 'timer_picker_sheet.dart';
import 'timer_settings_layout.dart';

class ForTimeSettings extends StatefulWidget {
  const ForTimeSettings({super.key, required this.beepService});

  final NativeBeepService beepService;

  @override
  ForTimeSettingsState createState() => ForTimeSettingsState();
}

class ForTimeSettingsState extends State<ForTimeSettings> {
  int _durationMinutes = 10;
  int _durationSeconds = 0;

  int get _totalSeconds => (_durationMinutes * 60) + _durationSeconds;

  String _formatTime(int minutes, int seconds) {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.forTimeColor;
    final l10n = AppLocalizations.of(context);
    final formatted = _formatTime(_durationMinutes, _durationSeconds);

    return TimerSettingsLayout(
      accentColor: accentColor,
      title: l10n.forTimeTitle,
      subtitle: l10n.forTimeDescription,
      icon: Icons.flag_outlined,
      content: [
        TimerSettingsTile(
          accentColor: accentColor,
          label: l10n.timeCap,
          value: formatted,
          helper: l10n.timeCapHelper,
          icon: Icons.hourglass_top,
          onTap: () {
            showTimerTimePicker(
              context: context,
              accentColor: accentColor,
              initialMinutes: _durationMinutes,
              initialSeconds: _durationSeconds,
              onMinutesChanged: (value) {
                setState(() => _durationMinutes = value);
              },
              onSecondsChanged: (value) {
                setState(() => _durationSeconds = value);
              },
            );
          },
        ),
      ],
      workoutDuration: formatted,
      primaryLabel: l10n.startTimer,
      onPrimaryPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimerScreen(
              duration: _totalSeconds,
              workoutName: l10n.forTimeTitle,
              accentColor: accentColor,
              beepService: widget.beepService,
            ),
          ),
        );
      },
    );
  }
}
