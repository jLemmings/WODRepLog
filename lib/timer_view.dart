import 'package:flutter/material.dart';

import 'theme.dart';
import 'timer_options/amrap_settings.dart';
import 'timer_options/emom_settings.dart';
import 'timer_options/for_time_settings.dart';
import 'timer_options/tabata_settings.dart';

class TimerView extends StatelessWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = _buildOptions(context);

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Timer Studio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? const Color(0xFF1C1C1E),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1F1F23),
              Color(0xFF141418),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose your format',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up the perfect timer overlay to match your session.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return _TimerModeCard(option: option);
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
    return [
      _TimerOptionData(
        title: 'AMRAP',
        subtitle: 'Push the pace for as many reps as you can manage.',
        icon: Icons.fitness_center,
        color: colorScheme.amrapColor,
        builder: (context) => const AmrapSettings(),
      ),
      _TimerOptionData(
        title: 'For Time',
        subtitle: 'Race the clock and lock in your best time.',
        icon: Icons.flag_circle,
        color: colorScheme.forTimeColor,
        builder: (context) => const ForTimeSettings(),
      ),
      _TimerOptionData(
        title: 'EMOM',
        subtitle: 'Automate your minute-by-minute training flow.',
        icon: Icons.schedule,
        color: colorScheme.emomColor,
        builder: (context) => const EmomSettings(),
      ),
      _TimerOptionData(
        title: 'Tabata',
        subtitle: 'Alternate intense work and focused rest.',
        icon: Icons.bolt,
        color: colorScheme.tabataColor,
        builder: (context) => const TabataSettings(),
      ),
    ];
  }
}

class _TimerModeCard extends StatelessWidget {
  const _TimerModeCard({
    required this.option,
  });

  final _TimerOptionData option;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: option.builder),
        ),
        borderRadius: BorderRadius.circular(24),
        splashColor: option.color.withValues(alpha: 0.1),
        highlightColor: option.color.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                option.color.withValues(alpha: 0.35),
                option.color.withValues(alpha: 0.12),
              ],
            ),
            border: Border.all(color: option.color.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: option.color.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(option.icon, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.75),
                size: 32,
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
