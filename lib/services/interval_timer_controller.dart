import 'dart:async';

import 'package:flutter/foundation.dart';

enum TimerPhase { countdown, work, rest, complete }

@immutable
class IntervalTimerState {
  const IntervalTimerState({
    required this.phase,
    required this.remaining,
    required this.phaseTotal,
    required this.currentRound,
    required this.totalRounds,
    required this.countdown,
    required this.countdownInitial,
    required this.isRunning,
    required this.isPaused,
  });

  final TimerPhase phase;
  final Duration remaining;
  final Duration phaseTotal;
  final int currentRound;
  final int totalRounds;
  final int countdown;
  final int countdownInitial;
  final bool isRunning;
  final bool isPaused;

  double get progress {
    if (phaseTotal.inMilliseconds <= 0) {
      return 0;
    }
    final clampedRemaining = remaining.inMilliseconds.clamp(0, phaseTotal.inMilliseconds);
    return 1 - (clampedRemaining / phaseTotal.inMilliseconds);
  }

  bool get isComplete => phase == TimerPhase.complete;

  IntervalTimerState copyWith({
    TimerPhase? phase,
    Duration? remaining,
    Duration? phaseTotal,
    int? currentRound,
    int? totalRounds,
    int? countdown,
    int? countdownInitial,
    bool? isRunning,
    bool? isPaused,
  }) {
    return IntervalTimerState(
      phase: phase ?? this.phase,
      remaining: remaining ?? this.remaining,
      phaseTotal: phaseTotal ?? this.phaseTotal,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      countdown: countdown ?? this.countdown,
      countdownInitial: countdownInitial ?? this.countdownInitial,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

class IntervalTimerController extends ChangeNotifier {
  IntervalTimerController({
    required this.workDuration,
    Duration? restDuration,
    int totalRounds = 1,
    int countdownSeconds = 3,
  })  : restDuration = (restDuration != null && !restDuration.isNegative && restDuration > Duration.zero)
            ? restDuration
            : null,
        totalRounds = totalRounds < 1 ? 1 : totalRounds,
        _countdownInitial = countdownSeconds < 0 ? 0 : countdownSeconds {
    _phaseRemaining = workDuration;
    _countdownRemaining = _countdownInitial;
    _initialiseState(notify: false);
  }

  final Duration workDuration;
  final Duration? restDuration;
  final int totalRounds;
  final int _countdownInitial;

  late IntervalTimerState _state;
  IntervalTimerState get state => _state;

  Timer? _phaseTimer;
  Timer? _countdownTimer;
  late Duration _phaseRemaining;
  late int _countdownRemaining;
  int _currentRound = 1;
  int? _nextRoundAfterRest;

  void start() {
    if (_state.isRunning) {
      return;
    }

    if (_state.phase == TimerPhase.complete) {
      _initialiseState();
    }

    if (_state.phase == TimerPhase.countdown && _countdownInitial > 0) {
      _startCountdown(resume: _state.isPaused);
    } else {
      _switchToWork(round: _currentRound);
    }
  }

  void pause() {
    if (!_state.isRunning || _state.isPaused || _state.phase == TimerPhase.complete) {
      return;
    }
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _emit(_state.copyWith(isRunning: false, isPaused: true));
  }

  void resume() {
    if (!_state.isPaused || _state.phase == TimerPhase.complete) {
      return;
    }
    if (_state.phase == TimerPhase.countdown) {
      _startCountdown(resume: true);
      return;
    }

    _emit(_state.copyWith(isRunning: true, isPaused: false));
    _startPhaseTimer(_state.phase == TimerPhase.work ? _onWorkComplete : _onRestComplete);
  }

  void reset() {
    _initialiseState();
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initialiseState({bool notify = true}) {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _currentRound = 1;
    _nextRoundAfterRest = null;
    _phaseRemaining = workDuration;
    _countdownRemaining = _countdownInitial;

    final initialPhase = _countdownInitial > 0 ? TimerPhase.countdown : TimerPhase.work;
    final initialRemaining = initialPhase == TimerPhase.countdown
        ? Duration(seconds: _countdownInitial)
        : workDuration;

    _emit(
      IntervalTimerState(
        phase: initialPhase,
        remaining: initialRemaining,
        phaseTotal: initialRemaining,
        currentRound: _currentRound,
        totalRounds: totalRounds,
        countdown: _countdownInitial,
        countdownInitial: _countdownInitial,
        isRunning: false,
        isPaused: false,
      ),
      notify: notify,
    );
  }

  void _emit(IntervalTimerState newState, {bool notify = true}) {
    _state = newState;
    if (notify) {
      notifyListeners();
    }
  }

  void _startCountdown({bool resume = false}) {
    _countdownTimer?.cancel();
    if (!resume) {
      _countdownRemaining = _countdownInitial;
    }

    if (_countdownRemaining <= 0) {
      _switchToWork(round: _currentRound);
      return;
    }

    _emit(
      _state.copyWith(
        phase: TimerPhase.countdown,
        phaseTotal: Duration(seconds: _countdownInitial),
        remaining: Duration(seconds: _countdownRemaining),
        countdown: _countdownRemaining,
        isRunning: true,
        isPaused: false,
      ),
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownRemaining <= 1) {
        timer.cancel();
        _countdownRemaining = 0;
        _emit(
          _state.copyWith(
            countdown: 0,
            remaining: Duration.zero,
          ),
        );
        _switchToWork(round: _currentRound);
      } else {
        _countdownRemaining -= 1;
        _emit(
          _state.copyWith(
            countdown: _countdownRemaining,
            remaining: Duration(seconds: _countdownRemaining),
          ),
        );
      }
    });
  }

  void _switchToWork({required int round}) {
    _phaseTimer?.cancel();
    _nextRoundAfterRest = null;
    _currentRound = round;
    _phaseRemaining = workDuration;

    _emit(
      _state.copyWith(
        phase: TimerPhase.work,
        phaseTotal: workDuration,
        remaining: workDuration,
        currentRound: _currentRound,
        countdown: 0,
        isRunning: true,
        isPaused: false,
      ),
    );

    _startPhaseTimer(_onWorkComplete);
  }

  void _switchToRest(int nextRound) {
    if (restDuration == null) {
      _switchToWork(round: nextRound);
      return;
    }

    _phaseTimer?.cancel();
    _nextRoundAfterRest = nextRound;
    _phaseRemaining = restDuration!;

    _emit(
      _state.copyWith(
        phase: TimerPhase.rest,
        phaseTotal: restDuration!,
        remaining: restDuration!,
        currentRound: nextRound,
        countdown: 0,
        isRunning: true,
        isPaused: false,
      ),
    );

    _startPhaseTimer(_onRestComplete);
  }

  void _startPhaseTimer(VoidCallback onComplete) {
    _phaseTimer?.cancel();

    if (_phaseRemaining <= Duration.zero) {
      onComplete();
      return;
    }

    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newRemaining = _phaseRemaining - const Duration(seconds: 1);
      if (newRemaining <= Duration.zero) {
        timer.cancel();
        _phaseRemaining = Duration.zero;
        _emit(_state.copyWith(remaining: Duration.zero));
        onComplete();
      } else {
        _phaseRemaining = newRemaining;
        _emit(_state.copyWith(remaining: newRemaining));
      }
    });
  }

  void _onWorkComplete() {
    if (_currentRound >= totalRounds) {
      _complete();
      return;
    }

    final nextRound = _currentRound + 1;
    if (restDuration != null) {
      _switchToRest(nextRound);
    } else {
      _switchToWork(round: nextRound);
    }
  }

  void _onRestComplete() {
    final nextRound = _nextRoundAfterRest ?? (_currentRound + 1);
    _nextRoundAfterRest = null;
    if (nextRound > totalRounds) {
      _complete();
    } else {
      _currentRound = nextRound;
      _switchToWork(round: _currentRound);
    }
  }

  void _complete() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _emit(
      _state.copyWith(
        phase: TimerPhase.complete,
        phaseTotal: Duration.zero,
        remaining: Duration.zero,
        countdown: 0,
        isRunning: false,
        isPaused: false,
        currentRound: totalRounds,
      ),
    );
  }
}
