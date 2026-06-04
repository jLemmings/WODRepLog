// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WODRepLog';

  @override
  String get appDescription => 'Proof-ready recording and timers';

  @override
  String get homeQuestion => 'What are you doing today?';

  @override
  String get homeSubtitle =>
      'Start a qualification recording or build a standalone workout timer.';

  @override
  String get recordProofTitle => 'Record Proof';

  @override
  String get recordProofSubtitle =>
      'Film qualification workouts with embedded athlete, event, workout, and timer overlays.';

  @override
  String get cameraEyebrow => 'Camera';

  @override
  String get workoutTimerTitle => 'Workout Timer';

  @override
  String get workoutTimerSubtitle =>
      'Run AMRAP, EMOM, For Time, or Tabata timers with clear workout-specific color cues.';

  @override
  String get timerEyebrow => 'Timer';

  @override
  String get settings => 'Settings';

  @override
  String get preferredLanguage => 'Preferred language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get englishLanguage => 'English';

  @override
  String get germanLanguage => 'German';

  @override
  String athleteGreeting(Object name) {
    return 'Athlete: $name';
  }

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get chooseFormatTitle => 'Choose format';

  @override
  String get chooseFormatSubtitle =>
      'Each timer keeps the controls simple and uses its own color while running.';

  @override
  String get configure => 'Configure';

  @override
  String get amrapTitle => 'AMRAP';

  @override
  String get amrapDescription =>
      'As many reps as possible within the clock you set.';

  @override
  String get amrapCardDescription => 'As many rounds or reps as possible.';

  @override
  String get forTimeTitle => 'For Time';

  @override
  String get forTimeDescription =>
      'Race the clock and capture your best effort.';

  @override
  String get forTimeCardDescription => 'Race a target time or time cap.';

  @override
  String get emomTitle => 'EMOM';

  @override
  String get emomDescription =>
      'Every minute on the minute with automated prompts.';

  @override
  String get emomCardDescription => 'Repeat work every minute or interval.';

  @override
  String get tabataTitle => 'Tabata';

  @override
  String get tabataDescription => 'Alternate intense work and purposeful rest.';

  @override
  String get tabataCardDescription => 'Alternate work and rest rounds.';

  @override
  String get duration => 'Duration';

  @override
  String get durationMinutes => 'Duration (minutes)';

  @override
  String get durationHelper => 'Tap to adjust minutes and seconds.';

  @override
  String get durationMinutesHelper =>
      'Timer counts down from the duration you set.';

  @override
  String get timeCap => 'Time cap';

  @override
  String get timeCapMinutes => 'Time cap (minutes)';

  @override
  String get timeCapHelper => 'Tap to pick minutes and seconds for your cap.';

  @override
  String get timeCapMinutesHelper =>
      'Timer counts up, showing the time cap and remaining time.';

  @override
  String get rounds => 'Rounds';

  @override
  String get roundsHelper => 'Total work intervals you want to complete.';

  @override
  String get tabataRoundsHelper => 'Number of cycles you want to complete.';

  @override
  String get intervalLength => 'Interval length';

  @override
  String get intervalLengthSeconds => 'Interval length (seconds)';

  @override
  String get intervalLengthHelper => 'Minutes and seconds for each round.';

  @override
  String get intervalLengthSecondsHelper =>
      'Length of each work period before the next start.';

  @override
  String get workInterval => 'Work interval';

  @override
  String get workIntervalHelper => 'Minutes and seconds for effort.';

  @override
  String get restInterval => 'Rest interval';

  @override
  String get restIntervalHelper => 'Dial in recovery between rounds.';

  @override
  String get startTimer => 'Start Timer';

  @override
  String get done => 'Done';

  @override
  String get timerTitle => 'Timer';

  @override
  String get workout => 'Workout';

  @override
  String get round => 'Round';

  @override
  String get elapsed => 'Elapsed';

  @override
  String get elapsedLowercase => 'elapsed';

  @override
  String get remaining => 'Remaining';

  @override
  String get remainingLowercase => 'remaining';

  @override
  String get nextStartLabel => 'Next start';

  @override
  String get getReady => 'Get ready';

  @override
  String get complete => 'Complete';

  @override
  String get timerPhase => 'Timer';

  @override
  String get rest => 'Rest';

  @override
  String get work => 'Work';

  @override
  String get workoutComplete => 'Workout complete';

  @override
  String get workoutCompleteMessage =>
      'Nice work! Take a breather or start another session.';

  @override
  String get restart => 'Restart';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get reset => 'Reset';

  @override
  String nextRest(Object time) {
    return 'Next: Rest $time';
  }

  @override
  String nextRound(Object round) {
    return 'Next: Round $round';
  }

  @override
  String failedInitializeCamera(Object error) {
    return 'Failed to initialize camera: $error';
  }

  @override
  String errorStartingRecording(Object error) {
    return 'Error starting video recording: $error';
  }

  @override
  String get videoSaved => 'Video with embedded overlay saved to gallery';

  @override
  String get failedSaveVideo => 'Failed to save video to gallery';

  @override
  String errorStoppingRecording(Object error) {
    return 'Error stopping video recording: $error';
  }

  @override
  String get stopBeforeClearing =>
      'Stop recording before clearing the overlay.';

  @override
  String get timerInactive => 'Timer inactive';

  @override
  String emomRound(Object round) {
    return 'EMOM • Round $round';
  }

  @override
  String amrapRemaining(Object time) {
    return 'AMRAP • $time remaining';
  }

  @override
  String forTimeElapsed(Object time) {
    return 'For Time • $time elapsed';
  }

  @override
  String nextStartIn(Object time) {
    return 'Next start in $time';
  }

  @override
  String cap(Object time) {
    return 'Cap $time';
  }

  @override
  String targetRemaining(Object target, Object remaining) {
    return 'Target $target • $remaining remaining';
  }

  @override
  String get event => 'Event';

  @override
  String get athlete => 'Athlete';

  @override
  String get tapDetailsOverlay =>
      'Tap Details to add athlete and workout overlay.';

  @override
  String get rec => 'REC';

  @override
  String get saving => 'SAVING';

  @override
  String get details => 'Details';

  @override
  String get recordingDetails => 'Recording Details';

  @override
  String get athleteName => 'Athlete name';

  @override
  String get athleteNameHint => 'e.g. Sam Briggs';

  @override
  String get eventName => 'Event name';

  @override
  String get eventNameHint => 'e.g. Wodapalooza Qualifier';

  @override
  String get workoutQualifierTitle => 'Workout / qualifier title';

  @override
  String get workoutTitleHint => 'e.g. Qualifier 1 - Heavy Grace';

  @override
  String get countdown => 'Countdown';

  @override
  String get startsIn => 'Starts in';

  @override
  String get countdownSeconds => 'Countdown (seconds)';

  @override
  String get countdownCaption =>
      'Delay the workout timer after recording starts.';

  @override
  String get enterCountdownSeconds => 'Enter countdown seconds';

  @override
  String get countdownNonNegative => 'Countdown must be 0 or higher';

  @override
  String get timerType => 'Timer type';

  @override
  String get timerTypeCaption =>
      'Choose a format to overlay alongside the recording.';

  @override
  String get selectTimerType => 'Select timer type';

  @override
  String get secondsExampleHint => 'e.g. 60';

  @override
  String get roundsExampleHint => 'e.g. 12';

  @override
  String get minutesExampleHint => 'e.g. 20';

  @override
  String get noTimerOverlay => 'No timer overlay';

  @override
  String get saveSettings => 'Save settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get noTimerOverlayMessage =>
      'No timer overlay will be shown. You can still start and stop recording normally.';

  @override
  String get roundsCaption => 'How many intervals the EMOM should run.';

  @override
  String get enterIntervalLength => 'Enter the interval length';

  @override
  String get intervalPositive => 'Interval must be a positive number';

  @override
  String get enterRounds => 'Enter number of rounds';

  @override
  String get roundsPositive => 'Rounds must be a positive number';

  @override
  String get enterDurationMinutes => 'Enter a duration in minutes';

  @override
  String get durationPositive => 'Provide a positive number of minutes';

  @override
  String minutesUnit(Object value) {
    return '$value min';
  }

  @override
  String secondsUnit(Object value) {
    return '$value sec';
  }

  @override
  String get summary => 'Summary';

  @override
  String timeRound(Object time, Object round) {
    return 'Time: $time\nRound: $round';
  }
}
