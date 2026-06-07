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
  int get _phaseRemaining => _snapshot.phaseRemaining;

  bool get _hasRounds => (widget.rounds ?? 0) > 0;
  bool get _hasRest => (widget.interval ?? 0) > 0;
  bool get _isComplete => _snapshot.isComplete;
  double get _phaseProgress => _snapshot.phaseProgress;

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.workoutName),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF061A25), Color(0xFF10182A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Column(
              children: [
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
        final size = math
            .min(constraints.maxWidth, math.max(260.0, constraints.maxHeight))
            .clamp(260.0, 390.0)
            .toDouble();

        return Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26),
            decoration: BoxDecoration(
              color: const Color(0xFF13283A).withValues(alpha: 0.56),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: SizedBox(
                width: size,
                height: size,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF141C2E),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: ClockPainter(
                      progress: _phaseProgress,
                      color: color,
                      trackColor: const Color(0xFF303746),
                      strokeWidth: 13,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _phaseLabel(context),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.62),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: Text(
                              _formatTime(_phaseRemaining),
                              key: ValueKey<int>(_phaseRemaining),
                              style: theme.textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );

    final outlinedStyle = OutlinedButton.styleFrom(
      fixedSize: const Size.fromHeight(56),
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF162338),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
