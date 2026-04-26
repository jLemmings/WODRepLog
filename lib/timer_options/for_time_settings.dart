import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    final formatted = _formatTime(_durationMinutes, _durationSeconds);

    return TimerSettingsLayout(
      accentColor: accentColor,
      title: 'For Time',
      subtitle: 'Race the clock and capture your best effort.',
      icon: Icons.flag_outlined,
      content: [
        TimerSettingsTile(
          accentColor: accentColor,
          label: 'Time cap',
          value: formatted,
          helper: 'Tap to pick minutes and seconds for your cap.',
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
      primaryLabel: 'Start Timer',
      onPrimaryPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimerScreen(
              duration: _totalSeconds,
              workoutName: 'For Time',
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
    final modalBackground = theme.colorScheme.primary;
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
                          backgroundColor: modalBackground,
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
                                '$index min',
                                style: pickerTextStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          backgroundColor: modalBackground,
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
                                    '$sec sec',
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
                    child: const Text('Done'),
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
