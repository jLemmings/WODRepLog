import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../timer_screen.dart';
import '../theme.dart';
import 'timer_settings_layout.dart';

class ForTimeSettings extends StatefulWidget {
  const ForTimeSettings({super.key});

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
            _showTimePicker(
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
            ),
          ),
        );
      },
    );
  }

  void _showTimePicker({
    required BuildContext context,
    required Color accentColor,
    required int initialMinutes,
    required int initialSeconds,
    required ValueChanged<int> onMinutesChanged,
    required ValueChanged<int> onSecondsChanged,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    const modalBackground = Color(0xFF101318);
    final pickerTextStyle = theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ) ??
        const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );
    final overlayColor = accentColor.withValues(alpha: 0.22);

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 320,
          decoration: BoxDecoration(
            color: modalBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 30,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: initialMinutes,
                          ),
                          selectionOverlay:
                              CupertinoPickerDefaultSelectionOverlay(
                            background: overlayColor,
                          ),
                          itemExtent: 34.0,
                          onSelectedItemChanged: (index) {
                            onMinutesChanged(index);
                          },
                          children: List.generate(
                            60,
                            (index) => Center(
                              child: Text(
                                l10n.minutesUnit(index),
                                style: pickerTextStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem:
                                [0, 15, 30, 45].indexOf(initialSeconds),
                          ),
                          selectionOverlay:
                              CupertinoPickerDefaultSelectionOverlay(
                            background: overlayColor,
                          ),
                          itemExtent: 34.0,
                          onSelectedItemChanged: (index) {
                            onSecondsChanged([0, 15, 30, 45][index]);
                          },
                          children: [0, 15, 30, 45]
                              .map(
                                (sec) => Center(
                                  child: Text(
                                    l10n.secondsUnit(sec),
                                    style: pickerTextStyle,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: modalBackground,
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: accentColor,
                    borderRadius: BorderRadius.circular(14),
                    child: Text(
                      l10n.done,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
