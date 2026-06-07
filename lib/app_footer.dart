import 'package:flutter/material.dart';

enum AppFooterItem { log, timer, stats }

class AppFooter extends StatelessWidget {
  const AppFooter({
    super.key,
    required this.activeItem,
    this.activeColor = const Color(0xFF347FFF),
    this.onLogTap,
    this.onTimerTap,
    this.onStatsTap,
  });

  final AppFooterItem activeItem;
  final Color activeColor;
  final VoidCallback? onLogTap;
  final VoidCallback? onTimerTap;
  final VoidCallback? onStatsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0E1520).withValues(alpha: 0.96),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(
                child: _FooterMenuItem(
                  icon: Icons.history_edu_rounded,
                  label: 'Log',
                  isActive: activeItem == AppFooterItem.log,
                  activeColor: activeColor,
                  onTap: onLogTap,
                ),
              ),
              Expanded(
                child: _FooterMenuItem(
                  icon: Icons.timer_rounded,
                  label: 'Timer',
                  isActive: activeItem == AppFooterItem.timer,
                  activeColor: activeColor,
                  onTap: onTimerTap,
                ),
              ),
              Expanded(
                child: _FooterMenuItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Stats',
                  isActive: activeItem == AppFooterItem.stats,
                  activeColor: activeColor,
                  onTap:
                      onStatsTap ??
                      () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(content: Text('Stats coming soon')),
                          );
                      },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterMenuItem extends StatelessWidget {
  const _FooterMenuItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isActive ? Colors.black : Colors.white;
    final background = isActive ? activeColor : Colors.transparent;
    final theme = Theme.of(context);

    return Material(
      color: background,
      child: InkWell(
        onTap: isActive ? null : onTap,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 22),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
