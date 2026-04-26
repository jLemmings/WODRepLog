import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final workLabel = _formatTime(_workMinutes, _workSeconds);
    final restLabel = _formatTime(_restMinutes, _restSeconds);
    final totalLabel = _formatTime(_totalTime ~/ 60, _totalTime % 60);

    return TimerSettingsLayout(
      accentColor: accentColor,
      title: l10n.tabataTitle,
      subtitle: l10n.tabataDescription,
      icon: Icons.loop,
      content: [
        TimerSettingsTile(
          accentColor: accentColor,
          label: l10n.rounds,
          value: '$_rounds',
          helper: l10n.tabataRoundsHelper,
          icon: Icons.replay_circle_filled,
          onTap: () {
            _showPicker(
              context: context,
              items: List<int>.generate(30, (index) => index + 1),
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
          label: l10n.workInterval,
          value: workLabel,
          helper: l10n.workIntervalHelper,
          icon: Icons.fitness_center,
          onTap: () {
            _showTimePicker(
              context: context,
              accentColor: accentColor,
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
          label: l10n.restInterval,
          value: restLabel,
          helper: l10n.restIntervalHelper,
          icon: Icons.bedtime,
          onTap: () {
            _showTimePicker(
              context: context,
              accentColor: accentColor,
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
      ],
      workoutDuration: totalLabel,
      primaryLabel: l10n.startTimer,
      onPrimaryPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimerScreen(
              duration: _workInterval,
              workoutName: l10n.tabataTitle,
              accentColor: accentColor,
              interval: _restInterval,
              rounds: _rounds,
              totalDuration: _totalTime,
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
    required Color accentColor,
    List<int> secondOptions = const [0, 15, 30, 45],
  }) {
    final initialSecondIndex = secondOptions.indexOf(initialSeconds);
    final secondsController = FixedExtentScrollController(
      initialItem: initialSecondIndex >= 0 ? initialSecondIndex : 0,
    );

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
                          scrollController: secondsController,
                          selectionOverlay:
                              CupertinoPickerDefaultSelectionOverlay(
                            background: overlayColor,
                          ),
                          itemExtent: 34.0,
                          onSelectedItemChanged: (index) {
                            onSecondsChanged(secondOptions[index]);
                          },
                          children: secondOptions
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

  void _showPicker({
    required BuildContext context,
    required List<int> items,
    required int initialValue,
    required ValueChanged<int> onSelectedItemChanged,
    required Color accentColor,
  }) {
    final initialIndex = items.indexOf(initialValue);
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
                  child: CupertinoPicker(
                    itemExtent: 34.0,
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex >= 0 ? initialIndex : 0,
                    ),
                    selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                      background: overlayColor,
                    ),
                    onSelectedItemChanged: (index) {
                      onSelectedItemChanged(items[index]);
                    },
                    children: items
                        .map(
                          (value) => Center(
                            child: Text(
                              value.toString(),
                              style: pickerTextStyle,
                            ),
                          ),
                        )
                        .toList(),
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
