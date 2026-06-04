import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'WODRepLog'**
  String get appTitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Proof-ready recording and timers'**
  String get appDescription;

  /// No description provided for @homeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What are you doing today?'**
  String get homeQuestion;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a qualification recording or build a standalone workout timer.'**
  String get homeSubtitle;

  /// No description provided for @recordProofTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Proof'**
  String get recordProofTitle;

  /// No description provided for @recordProofSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Film qualification workouts with embedded athlete, event, workout, and timer overlays.'**
  String get recordProofSubtitle;

  /// No description provided for @cameraEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraEyebrow;

  /// No description provided for @workoutTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Timer'**
  String get workoutTimerTitle;

  /// No description provided for @workoutTimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run AMRAP, EMOM, For Time, or Tabata timers with clear workout-specific color cues.'**
  String get workoutTimerSubtitle;

  /// No description provided for @timerEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timerEyebrow;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @preferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred language'**
  String get preferredLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @germanLanguage.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get germanLanguage;

  /// No description provided for @athleteGreeting.
  ///
  /// In en, this message translates to:
  /// **'Athlete: {name}'**
  String athleteGreeting(Object name);

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(Object version);

  /// No description provided for @chooseFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose format'**
  String get chooseFormatTitle;

  /// No description provided for @chooseFormatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each timer keeps the controls simple and uses its own color while running.'**
  String get chooseFormatSubtitle;

  /// No description provided for @configure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configure;

  /// No description provided for @amrapTitle.
  ///
  /// In en, this message translates to:
  /// **'AMRAP'**
  String get amrapTitle;

  /// No description provided for @amrapDescription.
  ///
  /// In en, this message translates to:
  /// **'As many reps as possible within the clock you set.'**
  String get amrapDescription;

  /// No description provided for @amrapCardDescription.
  ///
  /// In en, this message translates to:
  /// **'As many rounds or reps as possible.'**
  String get amrapCardDescription;

  /// No description provided for @forTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'For Time'**
  String get forTimeTitle;

  /// No description provided for @forTimeDescription.
  ///
  /// In en, this message translates to:
  /// **'Race the clock and capture your best effort.'**
  String get forTimeDescription;

  /// No description provided for @forTimeCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Race a target time or time cap.'**
  String get forTimeCardDescription;

  /// No description provided for @emomTitle.
  ///
  /// In en, this message translates to:
  /// **'EMOM'**
  String get emomTitle;

  /// No description provided for @emomDescription.
  ///
  /// In en, this message translates to:
  /// **'Every minute on the minute with automated prompts.'**
  String get emomDescription;

  /// No description provided for @emomCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Repeat work every minute or interval.'**
  String get emomCardDescription;

  /// No description provided for @tabataTitle.
  ///
  /// In en, this message translates to:
  /// **'Tabata'**
  String get tabataTitle;

  /// No description provided for @tabataDescription.
  ///
  /// In en, this message translates to:
  /// **'Alternate intense work and purposeful rest.'**
  String get tabataDescription;

  /// No description provided for @tabataCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Alternate work and rest rounds.'**
  String get tabataCardDescription;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get durationMinutes;

  /// No description provided for @durationHelper.
  ///
  /// In en, this message translates to:
  /// **'Tap to adjust minutes and seconds.'**
  String get durationHelper;

  /// No description provided for @durationMinutesHelper.
  ///
  /// In en, this message translates to:
  /// **'Timer counts down from the duration you set.'**
  String get durationMinutesHelper;

  /// No description provided for @timeCap.
  ///
  /// In en, this message translates to:
  /// **'Time cap'**
  String get timeCap;

  /// No description provided for @timeCapMinutes.
  ///
  /// In en, this message translates to:
  /// **'Time cap (minutes)'**
  String get timeCapMinutes;

  /// No description provided for @timeCapHelper.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick minutes and seconds for your cap.'**
  String get timeCapHelper;

  /// No description provided for @timeCapMinutesHelper.
  ///
  /// In en, this message translates to:
  /// **'Timer counts up, showing the time cap and remaining time.'**
  String get timeCapMinutesHelper;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get rounds;

  /// No description provided for @roundsHelper.
  ///
  /// In en, this message translates to:
  /// **'Total work intervals you want to complete.'**
  String get roundsHelper;

  /// No description provided for @tabataRoundsHelper.
  ///
  /// In en, this message translates to:
  /// **'Number of cycles you want to complete.'**
  String get tabataRoundsHelper;

  /// No description provided for @intervalLength.
  ///
  /// In en, this message translates to:
  /// **'Interval length'**
  String get intervalLength;

  /// No description provided for @intervalLengthSeconds.
  ///
  /// In en, this message translates to:
  /// **'Interval length (seconds)'**
  String get intervalLengthSeconds;

  /// No description provided for @intervalLengthHelper.
  ///
  /// In en, this message translates to:
  /// **'Minutes and seconds for each round.'**
  String get intervalLengthHelper;

  /// No description provided for @intervalLengthSecondsHelper.
  ///
  /// In en, this message translates to:
  /// **'Length of each work period before the next start.'**
  String get intervalLengthSecondsHelper;

  /// No description provided for @workInterval.
  ///
  /// In en, this message translates to:
  /// **'Work interval'**
  String get workInterval;

  /// No description provided for @workIntervalHelper.
  ///
  /// In en, this message translates to:
  /// **'Minutes and seconds for effort.'**
  String get workIntervalHelper;

  /// No description provided for @restInterval.
  ///
  /// In en, this message translates to:
  /// **'Rest interval'**
  String get restInterval;

  /// No description provided for @restIntervalHelper.
  ///
  /// In en, this message translates to:
  /// **'Dial in recovery between rounds.'**
  String get restIntervalHelper;

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start Timer'**
  String get startTimer;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @timerTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timerTitle;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// No description provided for @elapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed'**
  String get elapsed;

  /// No description provided for @elapsedLowercase.
  ///
  /// In en, this message translates to:
  /// **'elapsed'**
  String get elapsedLowercase;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @remainingLowercase.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remainingLowercase;

  /// No description provided for @nextStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Next start'**
  String get nextStartLabel;

  /// No description provided for @getReady.
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get getReady;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @timerPhase.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timerPhase;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @workoutComplete.
  ///
  /// In en, this message translates to:
  /// **'Workout complete'**
  String get workoutComplete;

  /// No description provided for @workoutCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Nice work! Take a breather or start another session.'**
  String get workoutCompleteMessage;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @nextRest.
  ///
  /// In en, this message translates to:
  /// **'Next: Rest {time}'**
  String nextRest(Object time);

  /// No description provided for @nextRound.
  ///
  /// In en, this message translates to:
  /// **'Next: Round {round}'**
  String nextRound(Object round);

  /// No description provided for @failedInitializeCamera.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize camera: {error}'**
  String failedInitializeCamera(Object error);

  /// No description provided for @errorStartingRecording.
  ///
  /// In en, this message translates to:
  /// **'Error starting video recording: {error}'**
  String errorStartingRecording(Object error);

  /// No description provided for @videoSaved.
  ///
  /// In en, this message translates to:
  /// **'Video with embedded overlay saved to gallery'**
  String get videoSaved;

  /// No description provided for @failedSaveVideo.
  ///
  /// In en, this message translates to:
  /// **'Failed to save video to gallery'**
  String get failedSaveVideo;

  /// No description provided for @errorStoppingRecording.
  ///
  /// In en, this message translates to:
  /// **'Error stopping video recording: {error}'**
  String errorStoppingRecording(Object error);

  /// No description provided for @stopBeforeClearing.
  ///
  /// In en, this message translates to:
  /// **'Stop recording before clearing the overlay.'**
  String get stopBeforeClearing;

  /// No description provided for @timerInactive.
  ///
  /// In en, this message translates to:
  /// **'Timer inactive'**
  String get timerInactive;

  /// No description provided for @emomRound.
  ///
  /// In en, this message translates to:
  /// **'EMOM • Round {round}'**
  String emomRound(Object round);

  /// No description provided for @amrapRemaining.
  ///
  /// In en, this message translates to:
  /// **'AMRAP • {time} remaining'**
  String amrapRemaining(Object time);

  /// No description provided for @forTimeElapsed.
  ///
  /// In en, this message translates to:
  /// **'For Time • {time} elapsed'**
  String forTimeElapsed(Object time);

  /// No description provided for @nextStartIn.
  ///
  /// In en, this message translates to:
  /// **'Next start in {time}'**
  String nextStartIn(Object time);

  /// No description provided for @cap.
  ///
  /// In en, this message translates to:
  /// **'Cap {time}'**
  String cap(Object time);

  /// No description provided for @targetRemaining.
  ///
  /// In en, this message translates to:
  /// **'Target {target} • {remaining} remaining'**
  String targetRemaining(Object target, Object remaining);

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @athlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get athlete;

  /// No description provided for @tapDetailsOverlay.
  ///
  /// In en, this message translates to:
  /// **'Tap Details to add athlete and workout overlay.'**
  String get tapDetailsOverlay;

  /// No description provided for @rec.
  ///
  /// In en, this message translates to:
  /// **'REC'**
  String get rec;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'SAVING'**
  String get saving;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @recordingDetails.
  ///
  /// In en, this message translates to:
  /// **'Recording Details'**
  String get recordingDetails;

  /// No description provided for @athleteName.
  ///
  /// In en, this message translates to:
  /// **'Athlete name'**
  String get athleteName;

  /// No description provided for @athleteNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sam Briggs'**
  String get athleteNameHint;

  /// No description provided for @eventName.
  ///
  /// In en, this message translates to:
  /// **'Event name'**
  String get eventName;

  /// No description provided for @eventNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Wodapalooza Qualifier'**
  String get eventNameHint;

  /// No description provided for @workoutQualifierTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout / qualifier title'**
  String get workoutQualifierTitle;

  /// No description provided for @workoutTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Qualifier 1 - Heavy Grace'**
  String get workoutTitleHint;

  /// No description provided for @countdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get countdown;

  /// No description provided for @startsIn.
  ///
  /// In en, this message translates to:
  /// **'Starts in'**
  String get startsIn;

  /// No description provided for @countdownSeconds.
  ///
  /// In en, this message translates to:
  /// **'Countdown (seconds)'**
  String get countdownSeconds;

  /// No description provided for @countdownCaption.
  ///
  /// In en, this message translates to:
  /// **'Delay the workout timer after recording starts.'**
  String get countdownCaption;

  /// No description provided for @enterCountdownSeconds.
  ///
  /// In en, this message translates to:
  /// **'Enter countdown seconds'**
  String get enterCountdownSeconds;

  /// No description provided for @countdownNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Countdown must be 0 or higher'**
  String get countdownNonNegative;

  /// No description provided for @timerType.
  ///
  /// In en, this message translates to:
  /// **'Timer type'**
  String get timerType;

  /// No description provided for @timerTypeCaption.
  ///
  /// In en, this message translates to:
  /// **'Choose a format to overlay alongside the recording.'**
  String get timerTypeCaption;

  /// No description provided for @selectTimerType.
  ///
  /// In en, this message translates to:
  /// **'Select timer type'**
  String get selectTimerType;

  /// No description provided for @secondsExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 60'**
  String get secondsExampleHint;

  /// No description provided for @roundsExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12'**
  String get roundsExampleHint;

  /// No description provided for @minutesExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 20'**
  String get minutesExampleHint;

  /// No description provided for @noTimerOverlay.
  ///
  /// In en, this message translates to:
  /// **'No timer overlay'**
  String get noTimerOverlay;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get saveSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noTimerOverlayMessage.
  ///
  /// In en, this message translates to:
  /// **'No timer overlay will be shown. You can still start and stop recording normally.'**
  String get noTimerOverlayMessage;

  /// No description provided for @roundsCaption.
  ///
  /// In en, this message translates to:
  /// **'How many intervals the EMOM should run.'**
  String get roundsCaption;

  /// No description provided for @enterIntervalLength.
  ///
  /// In en, this message translates to:
  /// **'Enter the interval length'**
  String get enterIntervalLength;

  /// No description provided for @intervalPositive.
  ///
  /// In en, this message translates to:
  /// **'Interval must be a positive number'**
  String get intervalPositive;

  /// No description provided for @enterRounds.
  ///
  /// In en, this message translates to:
  /// **'Enter number of rounds'**
  String get enterRounds;

  /// No description provided for @roundsPositive.
  ///
  /// In en, this message translates to:
  /// **'Rounds must be a positive number'**
  String get roundsPositive;

  /// No description provided for @enterDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Enter a duration in minutes'**
  String get enterDurationMinutes;

  /// No description provided for @durationPositive.
  ///
  /// In en, this message translates to:
  /// **'Provide a positive number of minutes'**
  String get durationPositive;

  /// No description provided for @minutesUnit.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String minutesUnit(Object value);

  /// No description provided for @secondsUnit.
  ///
  /// In en, this message translates to:
  /// **'{value} sec'**
  String secondsUnit(Object value);

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @timeRound.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}\nRound: {round}'**
  String timeRound(Object time, Object round);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
