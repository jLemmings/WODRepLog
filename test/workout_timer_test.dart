import 'package:flutter_test/flutter_test.dart';
import 'package:wodreplog/domain/workout_timer.dart';

void main() {
  group('WorkoutTimerEngine', () {
    test('completes a single-duration timer at the configured total', () {
      const engine = WorkoutTimerEngine(
        WorkoutTimerConfiguration(
          type: WorkoutTimerType.amrap,
          workSeconds: 3,
          totalSeconds: 3,
        ),
      );

      var snapshot = engine.initialSnapshot();

      snapshot = engine.tick(snapshot);
      expect(snapshot.phase, WorkoutTimerPhase.work);
      expect(snapshot.phaseRemaining, 2);
      expect(snapshot.overallElapsed, 1);

      snapshot = engine.tick(snapshot);
      snapshot = engine.tick(snapshot);
      expect(snapshot.phase, WorkoutTimerPhase.complete);
      expect(snapshot.totalRemaining, 0);
    });

    test('advances EMOM rounds without rest phases', () {
      final engine = WorkoutTimerEngine(
        WorkoutTimerConfiguration.emom(intervalSeconds: 2, rounds: 2),
      );

      var snapshot = engine.initialSnapshot();
      snapshot = engine.tick(snapshot);
      snapshot = engine.tick(snapshot);

      expect(snapshot.phase, WorkoutTimerPhase.work);
      expect(snapshot.currentRound, 2);
      expect(snapshot.phaseRemaining, 2);
      expect(snapshot.overallElapsed, 2);

      snapshot = engine.tick(snapshot);
      snapshot = engine.tick(snapshot);

      expect(snapshot.phase, WorkoutTimerPhase.complete);
      expect(snapshot.overallElapsed, 4);
    });

    test('advances Tabata work and rest phases', () {
      final engine = WorkoutTimerEngine(
        WorkoutTimerConfiguration.tabata(
          workSeconds: 2,
          restSeconds: 1,
          rounds: 2,
        ),
      );

      var snapshot = engine.initialSnapshot();
      snapshot = engine.tick(snapshot);
      snapshot = engine.tick(snapshot);

      expect(snapshot.phase, WorkoutTimerPhase.rest);
      expect(snapshot.currentRound, 1);
      expect(snapshot.phaseRemaining, 1);

      snapshot = engine.tick(snapshot);
      expect(snapshot.phase, WorkoutTimerPhase.work);
      expect(snapshot.currentRound, 2);

      snapshot = engine.tick(snapshot);
      snapshot = engine.tick(snapshot);
      expect(snapshot.phase, WorkoutTimerPhase.complete);
      expect(snapshot.totalWorkoutSeconds, 5);
    });
  });

  group('buildTimerOverlayLines', () {
    const labels = TimerOverlayLabels(
      countdown: 'Countdown',
      startsIn: 'Starts in',
      remaining: 'Remaining',
      round: 'Round',
      emom: 'EMOM',
      amrap: 'AMRAP',
      forTime: 'For Time',
      nextStart: 'Next start',
      elapsed: 'Elapsed',
      remainingSuffix: 'remaining',
      elapsedSuffix: 'elapsed',
    );

    test('builds countdown lines before workout timing starts', () {
      final lines = buildTimerOverlayLines(
        configuration: null,
        elapsedSeconds: 0,
        countdownRemaining: 3,
        labels: labels,
      );

      expect(lines.map((line) => line.value), ['Starts in', '3s']);
    });

    test('builds AMRAP remaining and elapsed lines', () {
      final lines = buildTimerOverlayLines(
        configuration: WorkoutTimerConfiguration.amrap(totalSeconds: 60),
        elapsedSeconds: 15,
        countdownRemaining: 0,
        labels: labels,
      );

      expect(lines[0].value, '00:45 remaining');
      expect(lines[1].value, '00:15');
    });

    test('builds EMOM round and next-start lines', () {
      final lines = buildTimerOverlayLines(
        configuration: WorkoutTimerConfiguration.emom(
          intervalSeconds: 60,
          rounds: 3,
        ),
        elapsedSeconds: 65,
        countdownRemaining: 0,
        labels: labels,
      );

      expect(lines[0].value, 'Round 2/3');
      expect(lines[1].value, '00:55');
    });
  });

  test('formatSeconds clamps negative values', () {
    expect(formatSeconds(-1), '00:00');
    expect(formatSeconds(65), '01:05');
  });
}
