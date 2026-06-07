import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class TimerSettingsLayout extends StatelessWidget {
  const TimerSettingsLayout({
    super.key,
    required this.accentColor,
    required this.title,
    required this.icon,
    required this.content,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.subtitle,
    this.workoutDuration,
  });

  final Color accentColor;
  final String title;
  final IconData icon;
  final List<Widget> content;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final String? subtitle;
  final String? workoutDuration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title),
        actions: [
          if (workoutDuration != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _HeaderDurationChip(
                accentColor: accentColor,
                duration: workoutDuration!,
              ),
            ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E1520), Color(0xFF122238)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _withSpacing(content),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1520).withValues(alpha: 0.92),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: FilledButton.icon(
                  onPressed: onPrimaryPressed,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(primaryLabel),
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderDurationChip extends StatelessWidget {
  const _HeaderDurationChip({
    required this.accentColor,
    required this.duration,
  });

  final Color accentColor;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, size: 16, color: accentColor),
          const SizedBox(width: 6),
          Text(
            duration,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class TimerTimeStepperCard extends StatelessWidget {
  const TimerTimeStepperCard({
    super.key,
    required this.accentColor,
    required this.label,
    required this.minutes,
    required this.seconds,
    required this.onMinutesChanged,
    required this.onSecondsChanged,
    this.helper,
    this.minuteStep = 1,
    this.secondStep = 15,
    this.maxMinutes = 99,
    this.maxSeconds = 45,
  });

  final Color accentColor;
  final String label;
  final int minutes;
  final int seconds;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<int> onSecondsChanged;
  final String? helper;
  final int minuteStep;
  final int secondStep;
  final int maxMinutes;
  final int maxSeconds;

  String get _displayValue =>
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

  void _changeMinutes(int delta) {
    onMinutesChanged((minutes + delta).clamp(0, maxMinutes).toInt());
  }

  void _changeSeconds(int delta) {
    onSecondsChanged((seconds + delta).clamp(0, maxSeconds).toInt());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF182A3E),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      label.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                if (helper != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    helper!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _displayValue,
                maxLines: 1,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: accentColor,
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StepperControl(
                    onIncrease: minutes < maxMinutes
                        ? () => _changeMinutes(minuteStep)
                        : null,
                    onDecrease: minutes > 0
                        ? () => _changeMinutes(-minuteStep)
                        : null,
                    unitLabel: 'min',
                  ),
                ),
                Container(width: 1, height: 48, color: Colors.white10),
                Expanded(
                  child: _StepperControl(
                    onIncrease: seconds < maxSeconds
                        ? () => _changeSeconds(secondStep)
                        : null,
                    onDecrease: seconds > 0
                        ? () => _changeSeconds(-secondStep)
                        : null,
                    unitLabel: 'sec',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimerNumberStepperCard extends StatelessWidget {
  const TimerNumberStepperCard({
    super.key,
    required this.accentColor,
    required this.label,
    required this.value,
    required this.onChanged,
    this.helper,
    this.minValue = 1,
    this.maxValue = 99,
    this.step = 1,
    this.unitLabel,
  });

  final Color accentColor;
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final String? helper;
  final int minValue;
  final int maxValue;
  final int step;
  final String? unitLabel;

  void _changeValue(int delta) {
    onChanged((value + delta).clamp(minValue, maxValue).toInt());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF182A3E),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      label.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                if (helper != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    helper!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$value',
                maxLines: 1,
                style: theme.textTheme.displayLarge?.copyWith(
                  color: accentColor,
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  height: 0.95,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: _NumberStepperControl(
              onIncrease: value < maxValue ? () => _changeValue(step) : null,
              onDecrease: value > minValue ? () => _changeValue(-step) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberStepperControl extends StatelessWidget {
  const _NumberStepperControl({
    required this.onIncrease,
    required this.onDecrease,
  });

  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StepButton(icon: Icons.add_rounded, onPressed: onIncrease),
        ),
        Container(width: 1, height: 48, color: Colors.white10),
        Expanded(
          child: _StepButton(icon: Icons.remove_rounded, onPressed: onDecrease),
        ),
      ],
    );
  }
}

class _StepperControl extends StatelessWidget {
  const _StepperControl({
    required this.onIncrease,
    required this.onDecrease,
    required this.unitLabel,
  });

  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final String unitLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _StepButton(icon: Icons.add_rounded, onPressed: onIncrease),
        ),
        SizedBox(
          width: 44,
          child: Text(
            unitLabel.toUpperCase(),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.76),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: _StepButton(icon: Icons.remove_rounded, onPressed: onDecrease),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: Colors.white,
      disabledColor: Colors.white.withValues(alpha: 0.22),
      style: IconButton.styleFrom(
        fixedSize: const Size(48, 48),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }
}

class TimerSettingsTile extends StatelessWidget {
  const TimerSettingsTile({
    super.key,
    required this.accentColor,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon,
    this.helper,
  });

  final Color accentColor;
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData? icon;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: accentColor.withValues(alpha: 0.15),
        highlightColor: accentColor.withValues(alpha: 0.1),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF182A3E),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 26),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (helper != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        helper!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.56),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerSummaryItem {
  const TimerSummaryItem({required this.label, required this.value});

  final String label;
  final String value;
}

class TimerSummaryCard extends StatelessWidget {
  const TimerSummaryCard({
    super.key,
    required this.accentColor,
    required this.items,
  });

  final Color accentColor;
  final List<TimerSummaryItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final dividerColor = Colors.white.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.assessment_outlined,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.summary,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;
            return Column(
              children: [
                Row(
                  children: [
                    Text(
                      item.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: dividerColor),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

List<Widget> _withSpacing(List<Widget> children) {
  if (children.isEmpty) {
    return children;
  }

  final spaced = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    spaced.add(children[i]);
    if (i != children.length - 1) {
      spaced.add(const SizedBox(height: 18));
    }
  }
  return spaced;
}
