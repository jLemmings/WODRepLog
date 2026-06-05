import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'services/app_services.dart';
import 'theme.dart';
import 'timer_options/amrap_settings.dart';
import 'timer_options/emom_settings.dart';
import 'timer_options/for_time_settings.dart';
import 'timer_options/tabata_settings.dart';

class TimerView extends StatelessWidget {
  const TimerView({super.key, required this.beepService});

  final NativeBeepService beepService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final options = _buildOptions(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.workoutTimerTitle),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF101318), Color(0xFF161A21)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.chooseFormatTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.chooseFormatSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.86,
                        ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      return _TimerModeCard(option: options[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_TimerOptionData> _buildOptions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return [
      _TimerOptionData(
        title: l10n.amrapTitle,
        subtitle: l10n.amrapCardDescription,
        icon: Icons.fitness_center_rounded,
        color: colorScheme.amrapColor,
        builder: (context) => AmrapSettings(beepService: beepService),
      ),
      _TimerOptionData(
        title: l10n.forTimeTitle,
        subtitle: l10n.forTimeCardDescription,
        icon: Icons.flag_rounded,
        color: colorScheme.forTimeColor,
        builder: (context) => ForTimeSettings(beepService: beepService),
      ),
      _TimerOptionData(
        title: l10n.emomTitle,
        subtitle: l10n.emomCardDescription,
        icon: Icons.schedule_rounded,
        color: colorScheme.emomColor,
        builder: (context) => EmomSettings(beepService: beepService),
      ),
      _TimerOptionData(
        title: l10n.tabataTitle,
        subtitle: l10n.tabataCardDescription,
        icon: Icons.bolt_rounded,
        color: colorScheme.tabataColor,
        builder: (context) => TabataSettings(beepService: beepService),
      ),
    ];
  }
}

class _TimerModeCard extends StatelessWidget {
  const _TimerModeCard({required this.option});

  final _TimerOptionData option;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: option.builder)),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1D222B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: option.color.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: option.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(option.icon, size: 28, color: option.color),
              ),
              const Spacer(),
              Text(
                option.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                option.subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.62),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    l10n.configure,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: option.color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: option.color,
                    size: 20,
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

class _TimerOptionData {
  const _TimerOptionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}
