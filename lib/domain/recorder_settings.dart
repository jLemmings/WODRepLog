import 'workout_timer.dart';

class RecorderSettings {
  const RecorderSettings({
    required this.athleteName,
    required this.eventName,
    required this.workoutTitle,
    required this.countdownSeconds,
    this.timerConfiguration,
  });

  final String athleteName;
  final String eventName;
  final String workoutTitle;
  final int countdownSeconds;
  final TimerConfiguration? timerConfiguration;
}
