import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../timer_screen.dart';
import '../theme.dart';
import 'timer_settings_layout.dart';

class EmomSettings extends StatefulWidget {
  const EmomSettings({super.key});

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
    final intervalLabel = _formatTime(_minutes, _seconds);
    final totalLabel = _formatTime(_totalTime ~/ 60, _totalTime % 60);

    return TimerSettingsLayout(
      accentColor: accentColor,
      title: 'EMOM',
      subtitle: 'Every minute on the minute with automated prompts.',
      icon: Icons.schedule,
      content: [
        TimerSettingsTile(
          accentColor: accentColor,
          label: 'Rounds',
          value: '$_rounds',
          helper: 'Total work intervals you want to complete.',
          icon: Icons.repeat,
          onTap: () {
            _showPicker(
              context: context,
              items: List<int>.generate(100, (index) => index + 1),
              initialValue: _rounds,
              onSelectedItemChanged: (value) {
                setState(() => _rounds = value);
              },
            );
          },
        ),
        TimerSettingsTile(
          accentColor: accentColor,
          label: 'Interval length',
          value: intervalLabel,
          helper: 'Minutes and seconds for each round.',
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
            TimerSummaryItem(label: 'Rounds', value: '$_rounds'),
            TimerSummaryItem(label: 'Interval', value: intervalLabel),
            TimerSummaryItem(label: 'Total Time', value: totalLabel),
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
              interval: _totalInterval,
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

  void _showPicker({
    required BuildContext context,
    required List<int> items,
    required int initialValue,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                    initialItem: initialValue - 1,
                  ),
                  onSelectedItemChanged: (index) {
                    onSelectedItemChanged(items[index]);
                  },
                  children: items
                      .map((item) => Center(child: Text(item.toString())))
                      .toList(),
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
