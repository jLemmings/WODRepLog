import 'dart:async';

import 'package:flutter/material.dart';

import 'clock_painter.dart';
import 'services/interval_timer_controller.dart';
import 'services/sound_service.dart';
import 'utils/time_utils.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({
    super.key,
    required this.duration,
    this.interval,
    this.rounds,
    this.countdownSeconds = 3,
  });

  final int duration;
  final int? interval;
  final int? rounds;
  final int countdownSeconds;

  Duration get _workDuration => Duration(seconds: duration);

  Duration? get _restDuration =>
      interval != null && interval! > 0 ? Duration(seconds: interval!) : null;

  int get _totalRounds => rounds ?? 1;

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> {
  late final IntervalTimerController _timerController;
  late final SoundService _soundService;
  IntervalTimerState? _previousState;

  @override
  void initState() {
    super.initState();
    _soundService = SoundService();
    _timerController = IntervalTimerController(
      workDuration: widget._workDuration,
      restDuration: widget._restDuration,
      totalRounds: widget._totalRounds,
      countdownSeconds: widget.countdownSeconds,
    )..addListener(_handleTimerUpdate);
    _timerController.start();
  }

  void _handleTimerUpdate() {
    final state = _timerController.state;
    final previous = _previousState;

    if (state.phase == TimerPhase.countdown && state.countdown > 0 && state.isRunning) {
      if (previous == null || previous.countdown != state.countdown) {
        unawaited(_soundService.playCountdownBeep());
      }
    } else if (state.phase == TimerPhase.work && state.isRunning &&
        (previous == null || previous.phase != TimerPhase.work)) {
      unawaited(_soundService.playStartBeep());
    } else if (state.phase == TimerPhase.rest && state.isRunning &&
        (previous == null || previous.phase != TimerPhase.rest)) {
      unawaited(_soundService.playRestBeep());
    }

    _previousState = state;
  }

  @override
  void dispose() {
    _timerController.removeListener(_handleTimerUpdate);
    _timerController.dispose();
    unawaited(_soundService.dispose());
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
        title: const Text('Timer'),
      ),
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _timerController,
            builder: (context, _) {
              final state = _timerController.state;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.phase == TimerPhase.countdown &&
                      state.countdown > 0)
                    _buildCountdown(state)
                  else if (state.isComplete)
                    _buildCompleteState()
                  else
                    _buildTimerDial(state),
                  const SizedBox(height: 24),
                  _buildTimerDetails(state),
                  const SizedBox(height: 32),
                  _buildControls(state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown(IntervalTimerState state) {
    return Column(
      children: [
        Text(
          'Starting in',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          state.countdown.toString(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildCompleteState() {
    return Column(
      children: [
        Icon(
          Icons.check_circle,
          size: 120,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(height: 16),
        Text(
          'Workout complete!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }

  Widget _buildTimerDial(IntervalTimerState state) {
    return CustomPaint(
      painter: ClockPainter(
        progress: state.progress,
        color: _phaseColor(context, state.phase),
      ),
      size: const Size(220, 220),
    );
  }

  Widget _buildTimerDetails(IntervalTimerState state) {
    if (state.isComplete) {
      return Text(
        'Great job! Tap restart to go again.',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      );
    }

    final durationText = formatDuration(state.remaining);
    final roundText = 'Round: ${state.currentRound}/${state.totalRounds}';
    final phaseText = _phaseLabel(state.phase);

    return Column(
      children: [
        Text(
          phaseText,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          durationText,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        if (state.totalRounds > 1) ...[
          const SizedBox(height: 8),
          Text(
            roundText,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ],
    );
  }

  void _resetTimer() {
    _previousState = null;
    _timerController.reset();
  }

  void _restartTimer() {
    _resetTimer();
    _timerController.start();
  }

  Widget _buildControls(IntervalTimerState state) {
    if (state.isComplete) {
      return ElevatedButton(
        onPressed: _restartTimer,
        child: const Text('Restart'),
      );
    }

    if (!state.isRunning && !state.isPaused) {
      return ElevatedButton(
        onPressed: _timerController.start,
        child: const Text('Start'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: state.isPaused ? _timerController.resume : _timerController.pause,
          child: Text(state.isPaused ? 'Resume' : 'Pause'),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: _resetTimer,
          child: const Text('Reset'),
        ),
      ],
    );
  }

  String _phaseLabel(TimerPhase phase) {
    switch (phase) {
      case TimerPhase.work:
        return 'Work';
      case TimerPhase.rest:
        return 'Rest';
      case TimerPhase.complete:
        return 'Completed';
      case TimerPhase.countdown:
        return 'Get ready';
    }
  }

  Color _phaseColor(BuildContext context, TimerPhase phase) {
    final scheme = Theme.of(context).colorScheme;
    switch (phase) {
      case TimerPhase.work:
        return scheme.primary;
      case TimerPhase.rest:
        return scheme.secondary;
      case TimerPhase.countdown:
        return scheme.tertiary;
      case TimerPhase.complete:
        return scheme.primary;
    }
  }
}
