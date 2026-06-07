import 'package:flutter/material.dart';

import 'app_footer.dart';
import 'app_header.dart';
import 'l10n/app_localizations.dart';
import 'services/app_services.dart';
import 'theme.dart';
import 'timer_options/amrap_settings.dart';
import 'timer_options/emom_settings.dart';
import 'timer_options/for_time_settings.dart';
import 'timer_options/tabata_settings.dart';

class TimerView extends StatelessWidget {
  const TimerView({
    super.key,
    required this.beepService,
    this.onLogTap,
    this.onStatsTap,
  });

  final NativeBeepService beepService;
  final VoidCallback? onLogTap;
  final VoidCallback? onStatsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final options = _buildOptions(context);

    return Scaffold(
      appBar: const AppHeader(),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E1520), Color(0xFF122238)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
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
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.74,
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
      bottomNavigationBar: AppFooter(
        activeItem: AppFooterItem.timer,
        activeColor: Theme.of(context).colorScheme.primary,
        onLogTap:
            onLogTap ??
            () => Navigator.of(context).popUntil((route) => route.isFirst),
        onStatsTap: onStatsTap,
      ),
    );
  }

  List<_TimerOptionData> _buildOptions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return [
      _TimerOptionData(
        title: l10n.amrapTitle,
        icon: Icons.change_circle_rounded,
        color: colorScheme.amrapColor,
        builder: (context) => AmrapSettings(beepService: beepService),
      ),
      _TimerOptionData(
        title: l10n.emomTitle,
        icon: Icons.timer_rounded,
        color: colorScheme.emomColor,
        builder: (context) => EmomSettings(beepService: beepService),
      ),
      _TimerOptionData(
        title: l10n.forTimeTitle,
        icon: Icons.timer_outlined,
        color: colorScheme.forTimeColor,
        builder: (context) => ForTimeSettings(beepService: beepService),
      ),
      _TimerOptionData(
        title: l10n.tabataTitle,
        icon: Icons.autorenew_rounded,
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: option.builder)),
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFF182A3E),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(option.icon, size: 70, color: option.color),
              const SizedBox(height: 34),
              Text(
                option.title.toUpperCase(),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.75),
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
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
    required this.icon,
    required this.color,
    required this.builder,
  });

  final String title;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;
}
