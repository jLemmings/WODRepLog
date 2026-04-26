import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
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
            _showPicker(
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
            _showTimePicker(
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

  void _showPicker({
    required BuildContext context,
    required List<int> items,
    required int initialValue,
    required ValueChanged<int> onSelectedItemChanged,
    required Color accentColor,
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

    final initialIndex = items.indexOf(initialValue);

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
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex >= 0 ? initialIndex : 0,
                    ),
                    selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                      background: overlayColor,
                    ),
                    itemExtent: 34.0,
                    onSelectedItemChanged: (index) {
                      onSelectedItemChanged(items[index]);
                    },
                    children: items
                        .map(
                          (item) => Center(
                            child: Text(
                              item.toString(),
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
