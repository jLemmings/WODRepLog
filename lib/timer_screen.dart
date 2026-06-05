import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'clock_painter.dart';
import 'domain/workout_timer.dart';
import 'l10n/app_localizations.dart';
import 'services/app_services.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({
    super.key,
    required this.duration,
    required this.workoutName,
    required this.accentColor,
    required this.beepService,
    this.interval,
    this.rounds,
    this.totalDuration,
  });

  final int duration;
  final String workoutName;
  final Color accentColor;
  final NativeBeepService beepService;
  final int? interval;
  final int? rounds;
  final int? totalDuration;

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
  static const int _countdownSeed = 3;
  static const Duration _countdownBeepDuration = Duration(milliseconds: 180);
  static const Duration _startBeepDuration = Duration(seconds: 2);

  late WorkoutTimerConfiguration _configuration;
  late WorkoutTimerEngine _engine;
  late WorkoutTimerSnapshot _snapshot;

  Timer? _timer;
  Timer? _countdownTimer;

  int _countdown = _countdownSeed;
  bool _isCountdownActive = true;
  bool _isPaused = false;
  WorkoutTimerPhase get _phase => _snapshot.phase;
  int get _currentRound => _snapshot.currentRound;
  int get _phaseRemaining => _snapshot.phaseRemaining;
  int get _overallElapsed => _snapshot.overallElapsed;

  bool get _hasRounds => (widget.rounds ?? 0) > 0;
  bool get _hasRest => (widget.interval ?? 0) > 0;
  bool get _isComplete => _snapshot.isComplete;
  double get _phaseProgress => _snapshot.phaseProgress;
  double get _totalProgress => _snapshot.totalProgress;
  int get _totalRemaining => _snapshot.totalRemaining;

  @override
  void initState() {
    super.initState();
    _bootstrapState();
    _startCountdown();
  }

  void _bootstrapState() {
    _configuration = WorkoutTimerConfiguration(
      type: _hasRest ? WorkoutTimerType.tabata : WorkoutTimerType.emom,
      workSeconds: widget.duration,
      restSeconds: widget.interval,
      rounds: widget.rounds,
      totalSeconds: widget.totalDuration ?? _deriveTotalSeconds(),
    );
    _engine = WorkoutTimerEngine(_configuration);
    _snapshot = _engine.initialSnapshot();
    _isPaused = false;
    _isCountdownActive = true;
    _countdown = _countdownSeed;
  }

  int _deriveTotalSeconds() {
    if (_hasRounds) {
      final rounds = widget.rounds!;
      final rest = _hasRest ? widget.interval! : 0;
      if (_hasRest) {
        return ((widget.duration + rest) * rounds) - rest;
      }
      return widget.duration * rounds;
    }
    return widget.duration;
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountdownActive = true;
      _countdown = _countdownSeed;
    });
    unawaited(_playCountdownBeep());

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (
      Timer countdownTimer,
    ) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
        if (_countdown == 0) {
          countdownTimer.cancel();
          unawaited(_playStartBeep());
          _startMainTimer();
        } else {
          unawaited(_playCountdownBeep());
        }
      }
    });
  }

  void _startMainTimer({bool fromResume = false}) {
    _countdownTimer?.cancel();
    _timer?.cancel();

    setState(() {
      _isPaused = false;
      _isCountdownActive = false;
      if (!fromResume && _isComplete) {
        _snapshot = _engine.initialSnapshot();
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _handleTick());
  }

  void _handleTick() {
    if (!mounted) return;

    setState(() {
      _snapshot = _engine.tick(_snapshot);
      if (_snapshot.isComplete) {
        _timer?.cancel();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    _startMainTimer(fromResume: true);
  }

  void _resetTimer() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    unawaited(_stopNativeBeep());

    setState(() {
      _bootstrapState();
    });

    _startCountdown();
  }

  Future<void> _playCountdownBeep() async {
    await _playNativeBeep(_countdownBeepDuration);
  }

  Future<void> _playStartBeep() async {
    await _playNativeBeep(_startBeepDuration);
  }

  Future<void> _playNativeBeep(Duration duration) async {
    await widget.beepService.play(duration);
  }

  Future<void> _stopNativeBeep() async {
    await widget.beepService.stop();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _phaseLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isComplete) {
      return l10n.complete;
    }
    if (!_hasRounds) {
      return l10n.timerPhase;
    }
    return _phase == WorkoutTimerPhase.rest ? l10n.rest : l10n.work;
  }

  String? _nextUpLabel(BuildContext context) {
    if (!_hasRounds || _isComplete) {
      return null;
    }

    final l10n = AppLocalizations.of(context);
    final totalRounds = widget.rounds ?? 0;

    if (_phase == WorkoutTimerPhase.work) {
      if (_hasRest && _currentRound < totalRounds) {
        return l10n.nextRest(_formatTime(widget.interval!));
      }
      if (_currentRound < totalRounds) {
        return l10n.nextRound(_currentRound + 1);
      }
    } else if (_phase == WorkoutTimerPhase.rest &&
        _currentRound < totalRounds) {
      return l10n.nextRound(_currentRound + 1);
    }

    return null;
  }

  Color _phaseColor(ColorScheme scheme) {
    return _phase == WorkoutTimerPhase.rest
        ? scheme.tertiary
        : widget.accentColor;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    unawaited(_stopNativeBeep());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.timerTitle),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF101015), Color(0xFF181820)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: Column(
              children: [
                _buildStatusCard(context),
                const SizedBox(height: 16),
                Expanded(
                  child: _isCountdownActive
                      ? _buildCountdown(context)
                      : _buildTimerVisualization(context),
                ),
                const SizedBox(height: 16),
                _buildControls(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final nextUpLabel = _nextUpLabel(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatusChip(
                  icon: _phase == WorkoutTimerPhase.rest
                      ? Icons.self_improvement
                      : Icons.fitness_center,
                  label: l10n.workout,
                  value: widget.workoutName,
                  background: _phaseColor(scheme).withValues(alpha: 0.18),
                  foreground: Colors.white,
                ),
              ),
              if (_hasRounds) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _StatusChip(
                    icon: Icons.repeat,
                    label: l10n.round,
                    value:
                        '$_currentRound${widget.rounds != null ? ' / ${widget.rounds}' : ''}',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _MetricTile(
                  label: l10n.elapsed,
                  value: _formatTime(_overallElapsed),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricTile(
                  label: l10n.remaining,
                  value: _formatTime(_totalRemaining),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _totalProgress,
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _phaseColor(scheme),
                    ),
                  ),
                ),
              ),
              if (nextUpLabel != null) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    nextUpLabel,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.getReady,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              _countdown.toString(),
              key: ValueKey<int>(_countdown),
              style: theme.textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontSize: 104,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerVisualization(BuildContext context) {
    final theme = Theme.of(context);
    final color = _phaseColor(theme.colorScheme);

    if (_isComplete) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_outlined, size: 64, color: color),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).workoutComplete,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).workoutCompleteMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = math.max(
          220.0,
          constraints.maxHeight - (_hasRounds ? 44 : 0),
        );
        final size = math
            .min(constraints.maxWidth, availableHeight)
            .clamp(220.0, 360.0)
            .toDouble();

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: ClockPainter(
                    progress: _phaseProgress,
                    color: color,
                    strokeWidth: 12,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _phaseLabel(context),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.68),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: Text(
                            _formatTime(_phaseRemaining),
                            key: ValueKey<int>(_phaseRemaining),
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_hasRounds) ...[
                const SizedBox(height: 18),
                Text(
                  '${AppLocalizations.of(context).round} $_currentRound${widget.rounds != null ? ' / ${widget.rounds}' : ''}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    if (_isCountdownActive) {
      return const SizedBox(height: 56);
    }

    final elevatedStyle = ElevatedButton.styleFrom(
      fixedSize: const Size.fromHeight(56),
      backgroundColor: _phaseColor(scheme),
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );

    final outlinedStyle = OutlinedButton.styleFrom(
      fixedSize: const Size.fromHeight(56),
      foregroundColor: Colors.white,
      side: BorderSide(color: Colors.white.withValues(alpha: 0.32)),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );

    if (_isComplete) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: elevatedStyle,
              onPressed: _resetTimer,
              icon: const Icon(Icons.replay),
              label: Text(l10n.restart),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              style: outlinedStyle,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check),
              label: Text(l10n.done),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: elevatedStyle,
            onPressed: _isPaused ? _resumeTimer : _pauseTimer,
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            label: Text(_isPaused ? l10n.resume : l10n.pause),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: outlinedStyle,
            onPressed: _resetTimer,
            icon: const Icon(Icons.restart_alt),
            label: Text(l10n.reset),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.value,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = background ?? Colors.white.withValues(alpha: 0.12);
    final fg = foreground ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg.withValues(alpha: 0.85), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: fg.withValues(alpha: 0.75),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
