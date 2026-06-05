import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

const _secondOptions = [0, 15, 30, 45];

void showTimerTimePicker({
  required BuildContext context,
  required Color accentColor,
  required int initialMinutes,
  required int initialSeconds,
  required ValueChanged<int> onMinutesChanged,
  required ValueChanged<int> onSecondsChanged,
  List<int> secondOptions = _secondOptions,
}) {
  final initialSecondIndex = secondOptions.indexOf(initialSeconds);
  final theme = Theme.of(context);
  final l10n = AppLocalizations.of(context);
  final pickerTextStyle = _pickerTextStyle(theme);
  final overlayColor = accentColor.withValues(alpha: 0.22);

  showCupertinoModalPopup(
    context: context,
    builder: (context) {
      return _PickerShell(
        accentColor: accentColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: initialMinutes,
                ),
                selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                  background: overlayColor,
                ),
                itemExtent: 34.0,
                onSelectedItemChanged: onMinutesChanged,
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
                  initialItem: initialSecondIndex >= 0 ? initialSecondIndex : 0,
                ),
                selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                  background: overlayColor,
                ),
                itemExtent: 34.0,
                onSelectedItemChanged: (index) {
                  onSecondsChanged(secondOptions[index]);
                },
                children: secondOptions
                    .map(
                      (seconds) => Center(
                        child: Text(
                          l10n.secondsUnit(seconds),
                          style: pickerTextStyle,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showTimerNumberPicker({
  required BuildContext context,
  required List<int> items,
  required int initialValue,
  required ValueChanged<int> onSelectedItemChanged,
  required Color accentColor,
}) {
  final initialIndex = items.indexOf(initialValue);
  final theme = Theme.of(context);
  final pickerTextStyle = _pickerTextStyle(theme);
  final overlayColor = accentColor.withValues(alpha: 0.22);

  showCupertinoModalPopup(
    context: context,
    builder: (context) {
      return _PickerShell(
        accentColor: accentColor,
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
                  child: Text(value.toString(), style: pickerTextStyle),
                ),
              )
              .toList(),
        ),
      );
    },
  );
}

TextStyle _pickerTextStyle(ThemeData theme) {
  return theme.textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ) ??
      const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      );
}

class _PickerShell extends StatelessWidget {
  const _PickerShell({required this.accentColor, required this.child});

  static const _modalBackground = Color(0xFF101318);

  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: _modalBackground,
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
            Expanded(child: child),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _modalBackground,
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
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
  }
}
