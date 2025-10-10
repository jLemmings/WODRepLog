import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../timer_screen.dart';
import '../theme.dart';
import 'timer_settings_layout.dart';

class AmrapSettings extends StatefulWidget {
  const AmrapSettings({super.key});

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
    final durationLabel = _formatTime(_minutes, _seconds);

    return TimerSettingsLayout(
      accentColor: accentColor,
      title: 'AMRAP',
      subtitle: 'As many reps as possible within the clock you set.',
      icon: Icons.fitness_center,
      content: [
        TimerSettingsTile(
          accentColor: accentColor,
          label: 'Duration',
          value: durationLabel,
          helper: 'Tap to adjust minutes and seconds.',
          icon: Icons.timelapse,
          onTap: () {
            _showTimePicker(
              context: context,
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
        TimerSummaryCard(
          accentColor: accentColor,
          items: [
            TimerSummaryItem(label: 'Total Time', value: durationLabel),
          ],
        ),
      ],
      primaryLabel: 'Start Timer',
      onPrimaryPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimerScreen(
              duration: _totalTime,
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
