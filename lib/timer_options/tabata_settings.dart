import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../timer_screen.dart';
import '../theme.dart';
import 'timer_settings_layout.dart';

class TabataSettings extends StatefulWidget {
  const TabataSettings({super.key});

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
    final workLabel = _formatTime(_workMinutes, _workSeconds);
    final restLabel = _formatTime(_restMinutes, _restSeconds);
    final totalLabel = _formatTime(_totalTime ~/ 60, _totalTime % 60);

    return TimerSettingsLayout(
      accentColor: accentColor,
      title: 'Tabata',
      subtitle: 'Alternate intense work and purposeful rest.',
      icon: Icons.loop,
      content: [
        TimerSettingsTile(
          accentColor: accentColor,
          label: 'Rounds',
          value: '$_rounds',
          helper: 'Number of cycles you want to complete.',
          icon: Icons.replay_circle_filled,
          onTap: () {
            _showPicker(
              context: context,
              items: List<int>.generate(30, (index) => index + 1),
              initialValue: _rounds,
              onSelectedItemChanged: (value) {
                setState(() => _rounds = value);
              },
            );
          },
        ),
        TimerSettingsTile(
          accentColor: accentColor,
          label: 'Work interval',
          value: workLabel,
          helper: 'Minutes and seconds for effort.',
          icon: Icons.fitness_center,
          onTap: () {
            _showTimePicker(
              context: context,
              initialMinutes: _workMinutes,
              initialSeconds: _workSeconds,
              onMinutesChanged: (value) {
                setState(() => _workMinutes = value);
              },
              onSecondsChanged: (value) {
                setState(() => _workSeconds = value);
              },
            );
          },
        ),
        TimerSettingsTile(
          accentColor: accentColor,
          label: 'Rest interval',
          value: restLabel,
          helper: 'Dial in recovery between rounds.',
          icon: Icons.bedtime,
          onTap: () {
            _showTimePicker(
              context: context,
              initialMinutes: _restMinutes,
              initialSeconds: _restSeconds,
              onMinutesChanged: (value) {
                setState(() => _restMinutes = value);
              },
              onSecondsChanged: (value) {
                setState(() => _restSeconds = value);
              },
            );
          },
        ),
        TimerSummaryCard(
          accentColor: accentColor,
          items: [
            TimerSummaryItem(label: 'Rounds', value: '$_rounds'),
            TimerSummaryItem(label: 'Work', value: workLabel),
            TimerSummaryItem(label: 'Rest', value: restLabel),
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
              duration: _workInterval,
              interval: _restInterval,
              rounds: _rounds,
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
    List<int> secondOptions = const [0, 15, 30, 45],
  }) {
    final initialSecondIndex = secondOptions.indexOf(initialSeconds);
    final secondsController = FixedExtentScrollController(
      initialItem: initialSecondIndex >= 0 ? initialSecondIndex : 0,
    );

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
                        scrollController: secondsController,
                        itemExtent: 32.0,
                        onSelectedItemChanged: (index) {
                          onSecondsChanged(secondOptions[index]);
                        },
                        children: secondOptions
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
    final initialIndex = items.indexOf(initialValue);
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex >= 0 ? initialIndex : 0,
                  ),
                  onSelectedItemChanged: (index) {
                    onSelectedItemChanged(items[index]);
                  },
                  children: items
                      .map((value) => Center(child: Text(value.toString())))
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
