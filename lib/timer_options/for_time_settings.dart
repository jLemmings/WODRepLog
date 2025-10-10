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
        TimerSummaryCard(
          accentColor: accentColor,
          items: [
            TimerSummaryItem(label: 'Time Cap', value: formatted),
          ],
        ),
      ],
      primaryLabel: 'Start Timer',
      onPrimaryPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimerScreen(
              duration: _totalSeconds,
            ),
          ),
        );
      },
    );
  }

  void _showTimePicker({
    required BuildContext context,
    required int initialMinutes,
    required int initialSeconds,
    required ValueChanged<int> onMinutesChanged,
    required ValueChanged<int> onSecondsChanged,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
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
                        itemExtent: 32.0,
                        onSelectedItemChanged: (index) {
                          onMinutesChanged(index);
                        },
                        children:
                            List.generate(60, (index) => Text('$index min')),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: [0, 15, 30, 45].indexOf(initialSeconds),
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (index) {
                          onSecondsChanged([0, 15, 30, 45][index]);
                        },
                        children: [0, 15, 30, 45]
                            .map((sec) => Text('$sec sec'))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                child: const Text('Done'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
