import 'dart:math' as math;

enum WorkoutTimerType { emom, amrap, forTime, tabata }

enum WorkoutTimerPhase { work, rest, complete }

typedef TimerConfiguration = WorkoutTimerConfiguration;

class WorkoutTimerConfiguration {
  const WorkoutTimerConfiguration({
    required this.type,
    int? workSeconds,
    int? intervalSeconds,
    this.restSeconds,
    this.rounds,
    this.totalSeconds,
  }) : workSeconds = workSeconds ?? intervalSeconds;

  factory WorkoutTimerConfiguration.amrap({required int totalSeconds}) {
    return WorkoutTimerConfiguration(
      type: WorkoutTimerType.amrap,
      workSeconds: totalSeconds,
      totalSeconds: totalSeconds,
    );
  }

  factory WorkoutTimerConfiguration.forTime({required int totalSeconds}) {
    return WorkoutTimerConfiguration(
      type: WorkoutTimerType.forTime,
      workSeconds: totalSeconds,
      totalSeconds: totalSeconds,
    );
  }

  factory WorkoutTimerConfiguration.emom({
    required int intervalSeconds,
    required int rounds,
  }) {
    return WorkoutTimerConfiguration(
      type: WorkoutTimerType.emom,
      workSeconds: intervalSeconds,
      rounds: rounds,
      totalSeconds: intervalSeconds * rounds,
    );
  }

  factory WorkoutTimerConfiguration.tabata({
    required int workSeconds,
    required int restSeconds,
    required int rounds,
  }) {
    return WorkoutTimerConfiguration(
      type: WorkoutTimerType.tabata,
      workSeconds: workSeconds,
      restSeconds: restSeconds,
      rounds: rounds,
      totalSeconds: (rounds * (workSeconds + restSeconds)) - restSeconds,
    );
  }

  final WorkoutTimerType type;
  final int? workSeconds;
  final int? restSeconds;
  final int? rounds;
  final int? totalSeconds;

  int? get intervalSeconds => workSeconds;
  int get primaryWorkSeconds => math.max(workSeconds ?? totalSeconds ?? 0, 0);
  int get totalWorkoutSeconds =>
      math.max(totalSeconds ?? _deriveTotalSeconds(), 0);
  int get roundCount => math.max(rounds ?? 0, 0);
  int get restIntervalSeconds => math.max(restSeconds ?? 0, 0);
  bool get hasRounds => roundCount > 0;
  bool get hasRest => restIntervalSeconds > 0;

  int _deriveTotalSeconds() {
    if (!hasRounds) return primaryWorkSeconds;
    if (!hasRest) return primaryWorkSeconds * roundCount;
    return (roundCount * (primaryWorkSeconds + restIntervalSeconds)) -
        restIntervalSeconds;
  }
}

class WorkoutTimerSnapshot {
  const WorkoutTimerSnapshot({
    required this.phase,
    required this.currentRound,
    required this.phaseDuration,
    required this.phaseRemaining,
    required this.overallElapsed,
    required this.totalWorkoutSeconds,
  });

  final WorkoutTimerPhase phase;
  final int currentRound;
  final int phaseDuration;
  final int phaseRemaining;
  final int overallElapsed;
  final int totalWorkoutSeconds;

  bool get isComplete => phase == WorkoutTimerPhase.complete;

  int get totalRemaining =>
      (totalWorkoutSeconds - overallElapsed).clamp(0, totalWorkoutSeconds);

  double get phaseProgress =>
      phaseDuration == 0 ? 0 : 1 - (phaseRemaining / phaseDuration);

  double get totalProgress => totalWorkoutSeconds == 0
      ? 0
      : (overallElapsed / totalWorkoutSeconds).clamp(0, 1).toDouble();

  WorkoutTimerSnapshot copyWith({
    WorkoutTimerPhase? phase,
    int? currentRound,
    int? phaseDuration,
    int? phaseRemaining,
    int? overallElapsed,
    int? totalWorkoutSeconds,
  }) {
    return WorkoutTimerSnapshot(
      phase: phase ?? this.phase,
      currentRound: currentRound ?? this.currentRound,
      phaseDuration: phaseDuration ?? this.phaseDuration,
      phaseRemaining: phaseRemaining ?? this.phaseRemaining,
      overallElapsed: overallElapsed ?? this.overallElapsed,
      totalWorkoutSeconds: totalWorkoutSeconds ?? this.totalWorkoutSeconds,
    );
  }
}

class WorkoutTimerEngine {
  const WorkoutTimerEngine(this.configuration);

  final WorkoutTimerConfiguration configuration;

  WorkoutTimerSnapshot initialSnapshot() {
    final duration = configuration.primaryWorkSeconds;
    return WorkoutTimerSnapshot(
      phase: duration <= 0
          ? WorkoutTimerPhase.complete
          : WorkoutTimerPhase.work,
      currentRound: 1,
      phaseDuration: duration,
      phaseRemaining: duration,
      overallElapsed: 0,
      totalWorkoutSeconds: configuration.totalWorkoutSeconds,
    );
  }

  WorkoutTimerSnapshot tick(WorkoutTimerSnapshot snapshot) {
    if (snapshot.isComplete) return snapshot;

    final elapsed = (snapshot.overallElapsed + 1)
        .clamp(0, snapshot.totalWorkoutSeconds)
        .toInt();
    final remaining = math.max(snapshot.phaseRemaining - 1, 0);

    if (remaining > 0) {
      return snapshot.copyWith(
        phaseRemaining: remaining,
        overallElapsed: elapsed,
      );
    }

    return _nextPhase(snapshot, elapsed) ??
        snapshot.copyWith(
          phase: WorkoutTimerPhase.complete,
          phaseRemaining: 0,
          overallElapsed: elapsed,
        );
  }

  WorkoutTimerSnapshot? _nextPhase(WorkoutTimerSnapshot snapshot, int elapsed) {
    if (!configuration.hasRounds) return null;

    final totalRounds = configuration.roundCount;
    if (snapshot.phase == WorkoutTimerPhase.work) {
      if (configuration.hasRest && snapshot.currentRound < totalRounds) {
        return snapshot.copyWith(
          phase: WorkoutTimerPhase.rest,
          phaseDuration: configuration.restIntervalSeconds,
          phaseRemaining: configuration.restIntervalSeconds,
          overallElapsed: elapsed,
        );
      }

      if (snapshot.currentRound < totalRounds) {
        return snapshot.copyWith(
          phase: WorkoutTimerPhase.work,
          currentRound: snapshot.currentRound + 1,
          phaseDuration: configuration.primaryWorkSeconds,
          phaseRemaining: configuration.primaryWorkSeconds,
          overallElapsed: elapsed,
        );
      }

      return null;
    }

    if (snapshot.phase == WorkoutTimerPhase.rest &&
        snapshot.currentRound < totalRounds) {
      return snapshot.copyWith(
        phase: WorkoutTimerPhase.work,
        currentRound: snapshot.currentRound + 1,
        phaseDuration: configuration.primaryWorkSeconds,
        phaseRemaining: configuration.primaryWorkSeconds,
        overallElapsed: elapsed,
      );
    }

    return null;
  }
}

class TimerOverlayLine {
  const TimerOverlayLine(this.label, this.value);

  final String label;
  final String value;
}

class TimerOverlayLabels {
  const TimerOverlayLabels({
    required this.countdown,
    required this.startsIn,
    required this.remaining,
    required this.round,
    required this.emom,
    required this.amrap,
    required this.forTime,
    required this.nextStart,
    required this.elapsed,
    required this.remainingSuffix,
    required this.elapsedSuffix,
  });

  final String countdown;
  final String startsIn;
  final String remaining;
  final String round;
  final String emom;
  final String amrap;
  final String forTime;
  final String nextStart;
  final String elapsed;
  final String remainingSuffix;
  final String elapsedSuffix;
}

List<TimerOverlayLine> buildTimerOverlayLines({
  required WorkoutTimerConfiguration? configuration,
  required int elapsedSeconds,
  required int countdownRemaining,
  required TimerOverlayLabels labels,
}) {
  if (countdownRemaining > 0) {
    return [
      TimerOverlayLine(labels.countdown, labels.startsIn),
      TimerOverlayLine(labels.remaining, '${countdownRemaining}s'),
    ];
  }

  final config = configuration;
  if (config == null) return const [];

  final elapsed = math.max(elapsedSeconds, 0);
  switch (config.type) {
    case WorkoutTimerType.emom:
      final interval = math.max(config.primaryWorkSeconds, 1);
      final rounds = config.roundCount;
      final roundIndex = (elapsed ~/ interval) + 1;
      final currentRound = rounds > 0
          ? math.min(roundIndex, rounds)
          : roundIndex;
      final primary = rounds > 0
          ? '${labels.round} $currentRound/$rounds'
          : '${labels.round} $currentRound';
      final remaining = interval - (elapsed % interval);
      return [
        TimerOverlayLine(labels.emom, primary),
        TimerOverlayLine(labels.nextStart, formatSeconds(remaining)),
        TimerOverlayLine(labels.elapsed, formatSeconds(elapsed)),
      ];
    case WorkoutTimerType.amrap:
      final remaining = math.max(config.totalWorkoutSeconds - elapsed, 0);
      return [
        TimerOverlayLine(
          labels.amrap,
          '${formatSeconds(remaining)} ${labels.remainingSuffix}',
        ),
        TimerOverlayLine(labels.elapsed, formatSeconds(elapsed)),
      ];
    case WorkoutTimerType.forTime:
      final remaining = math.max(config.totalWorkoutSeconds - elapsed, 0);
      return [
        TimerOverlayLine(
          labels.forTime,
          '${formatSeconds(elapsed)} ${labels.elapsedSuffix}',
        ),
        TimerOverlayLine(labels.remaining, formatSeconds(remaining)),
      ];
    case WorkoutTimerType.tabata:
      final engine = WorkoutTimerEngine(config);
      var snapshot = engine.initialSnapshot();
      for (var i = 0; i < elapsed && !snapshot.isComplete; i++) {
        snapshot = engine.tick(snapshot);
      }
      final phaseLabel = snapshot.phase == WorkoutTimerPhase.rest
          ? labels.remaining
          : labels.round;
      return [
        TimerOverlayLine(
          labels.round,
          '${snapshot.currentRound}/${config.roundCount}',
        ),
        TimerOverlayLine(phaseLabel, formatSeconds(snapshot.phaseRemaining)),
        TimerOverlayLine(labels.elapsed, formatSeconds(elapsed)),
      ];
  }
}

String formatSeconds(int totalSeconds) {
  final safeSeconds = math.max(totalSeconds, 0);
  final minutes = safeSeconds ~/ 60;
  final seconds = safeSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
