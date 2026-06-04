// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'WODRepLog';

  @override
  String get appDescription => 'Nachweisfertige Aufnahmen und Timer';

  @override
  String get homeQuestion => 'Was steht heute an?';

  @override
  String get homeSubtitle =>
      'Starte eine Qualifikationsaufnahme oder erstelle einen eigenständigen Workout-Timer.';

  @override
  String get recordProofTitle => 'Nachweis aufnehmen';

  @override
  String get recordProofSubtitle =>
      'Filme Qualifikations-Workouts mit eingeblendeten Angaben zu Athlet, Event, Workout und Timer.';

  @override
  String get cameraEyebrow => 'Kamera';

  @override
  String get workoutTimerTitle => 'Workout-Timer';

  @override
  String get workoutTimerSubtitle =>
      'Starte AMRAP-, EMOM-, For-Time- oder Tabata-Timer mit klaren workout-spezifischen Farben.';

  @override
  String get timerEyebrow => 'Timer';

  @override
  String get settings => 'Einstellungen';

  @override
  String get preferredLanguage => 'Bevorzugte Sprache';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get englishLanguage => 'Englisch';

  @override
  String get germanLanguage => 'Deutsch';

  @override
  String athleteGreeting(Object name) {
    return 'Athlet: $name';
  }

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get chooseFormatTitle => 'Format wählen';

  @override
  String get chooseFormatSubtitle =>
      'Jeder Timer bleibt einfach bedienbar und nutzt beim Lauf seine eigene Farbe.';

  @override
  String get configure => 'Konfigurieren';

  @override
  String get amrapTitle => 'AMRAP';

  @override
  String get amrapDescription =>
      'So viele Wiederholungen wie möglich innerhalb der eingestellten Zeit.';

  @override
  String get amrapCardDescription =>
      'So viele Runden oder Wiederholungen wie möglich.';

  @override
  String get forTimeTitle => 'For Time';

  @override
  String get forTimeDescription =>
      'Gegen die Uhr arbeiten und deine beste Leistung festhalten.';

  @override
  String get forTimeCardDescription =>
      'Gegen eine Zielzeit oder ein Zeitlimit antreten.';

  @override
  String get emomTitle => 'EMOM';

  @override
  String get emomDescription =>
      'Every minute on the minute mit automatischen Hinweisen.';

  @override
  String get emomCardDescription =>
      'Arbeit jede Minute oder jedes Intervall wiederholen.';

  @override
  String get tabataTitle => 'Tabata';

  @override
  String get tabataDescription =>
      'Intensive Arbeit und gezielte Erholung abwechseln.';

  @override
  String get tabataCardDescription => 'Arbeits- und Pausenrunden abwechseln.';

  @override
  String get duration => 'Dauer';

  @override
  String get durationMinutes => 'Dauer (Minuten)';

  @override
  String get durationHelper => 'Tippen, um Minuten und Sekunden anzupassen.';

  @override
  String get durationMinutesHelper =>
      'Der Timer zählt von der eingestellten Dauer herunter.';

  @override
  String get timeCap => 'Zeitlimit';

  @override
  String get timeCapMinutes => 'Zeitlimit (Minuten)';

  @override
  String get timeCapHelper =>
      'Tippen, um Minuten und Sekunden für das Limit zu wählen.';

  @override
  String get timeCapMinutesHelper =>
      'Der Timer zählt hoch und zeigt Zeitlimit sowie Restzeit.';

  @override
  String get rounds => 'Runden';

  @override
  String get roundsHelper => 'Gesamtzahl der Arbeitsintervalle.';

  @override
  String get tabataRoundsHelper =>
      'Anzahl der Zyklen, die du abschließen möchtest.';

  @override
  String get intervalLength => 'Intervalllänge';

  @override
  String get intervalLengthSeconds => 'Intervalllänge (Sekunden)';

  @override
  String get intervalLengthHelper => 'Minuten und Sekunden pro Runde.';

  @override
  String get intervalLengthSecondsHelper =>
      'Länge jeder Arbeitsphase bis zum nächsten Start.';

  @override
  String get workInterval => 'Arbeitsintervall';

  @override
  String get workIntervalHelper => 'Minuten und Sekunden für die Belastung.';

  @override
  String get restInterval => 'Pausenintervall';

  @override
  String get restIntervalHelper => 'Erholung zwischen den Runden festlegen.';

  @override
  String get startTimer => 'Timer starten';

  @override
  String get done => 'Fertig';

  @override
  String get timerTitle => 'Timer';

  @override
  String get workout => 'Workout';

  @override
  String get round => 'Runde';

  @override
  String get elapsed => 'Vergangen';

  @override
  String get elapsedLowercase => 'vergangen';

  @override
  String get remaining => 'Verbleibend';

  @override
  String get remainingLowercase => 'verbleibend';

  @override
  String get nextStartLabel => 'Nächster Start';

  @override
  String get getReady => 'Bereit machen';

  @override
  String get complete => 'Fertig';

  @override
  String get timerPhase => 'Timer';

  @override
  String get rest => 'Pause';

  @override
  String get work => 'Arbeit';

  @override
  String get workoutComplete => 'Workout abgeschlossen';

  @override
  String get workoutCompleteMessage =>
      'Stark. Kurz durchatmen oder direkt die nächste Einheit starten.';

  @override
  String get restart => 'Neu starten';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String nextRest(Object time) {
    return 'Als Nächstes: Pause $time';
  }

  @override
  String nextRound(Object round) {
    return 'Als Nächstes: Runde $round';
  }

  @override
  String failedInitializeCamera(Object error) {
    return 'Kamera konnte nicht initialisiert werden: $error';
  }

  @override
  String errorStartingRecording(Object error) {
    return 'Fehler beim Starten der Videoaufnahme: $error';
  }

  @override
  String get videoSaved =>
      'Video mit eingebettetem Overlay wurde in der Galerie gespeichert';

  @override
  String get failedSaveVideo =>
      'Video konnte nicht in der Galerie gespeichert werden';

  @override
  String errorStoppingRecording(Object error) {
    return 'Fehler beim Stoppen der Videoaufnahme: $error';
  }

  @override
  String get stopBeforeClearing =>
      'Stoppe die Aufnahme, bevor du das Overlay zurücksetzt.';

  @override
  String get timerInactive => 'Timer inaktiv';

  @override
  String emomRound(Object round) {
    return 'EMOM • Runde $round';
  }

  @override
  String amrapRemaining(Object time) {
    return 'AMRAP • $time verbleibend';
  }

  @override
  String forTimeElapsed(Object time) {
    return 'For Time • $time vergangen';
  }

  @override
  String nextStartIn(Object time) {
    return 'Nächster Start in $time';
  }

  @override
  String cap(Object time) {
    return 'Limit $time';
  }

  @override
  String targetRemaining(Object target, Object remaining) {
    return 'Ziel $target • $remaining verbleibend';
  }

  @override
  String get event => 'Event';

  @override
  String get athlete => 'Athlet';

  @override
  String get tapDetailsOverlay =>
      'Tippe auf Details, um Athlet und Workout zum Overlay hinzuzufügen.';

  @override
  String get rec => 'REC';

  @override
  String get saving => 'SPEICHERN';

  @override
  String get details => 'Details';

  @override
  String get recordingDetails => 'Aufnahmedetails';

  @override
  String get athleteName => 'Name des Athleten';

  @override
  String get athleteNameHint => 'z. B. Sam Briggs';

  @override
  String get eventName => 'Eventname';

  @override
  String get eventNameHint => 'z. B. Wodapalooza Qualifier';

  @override
  String get workoutQualifierTitle => 'Workout / Qualifier-Titel';

  @override
  String get workoutTitleHint => 'z. B. Qualifier 1 - Heavy Grace';

  @override
  String get countdown => 'Countdown';

  @override
  String get startsIn => 'Start in';

  @override
  String get countdownSeconds => 'Countdown (Sekunden)';

  @override
  String get countdownCaption =>
      'Verzögert den Workout-Timer nach dem Start der Aufnahme.';

  @override
  String get enterCountdownSeconds => 'Gib die Countdown-Sekunden ein';

  @override
  String get countdownNonNegative => 'Der Countdown muss 0 oder höher sein';

  @override
  String get timerType => 'Timer-Typ';

  @override
  String get timerTypeCaption =>
      'Wähle ein Format, das in der Aufnahme eingeblendet wird.';

  @override
  String get selectTimerType => 'Timer-Typ auswählen';

  @override
  String get secondsExampleHint => 'z. B. 60';

  @override
  String get roundsExampleHint => 'z. B. 12';

  @override
  String get minutesExampleHint => 'z. B. 20';

  @override
  String get noTimerOverlay => 'Kein Timer-Overlay';

  @override
  String get saveSettings => 'Einstellungen speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get noTimerOverlayMessage =>
      'Es wird kein Timer-Overlay angezeigt. Du kannst trotzdem normal aufnehmen.';

  @override
  String get roundsCaption => 'Wie viele Intervalle das EMOM laufen soll.';

  @override
  String get enterIntervalLength => 'Gib die Intervalllänge ein';

  @override
  String get intervalPositive => 'Das Intervall muss eine positive Zahl sein';

  @override
  String get enterRounds => 'Gib die Anzahl der Runden ein';

  @override
  String get roundsPositive => 'Die Runden müssen eine positive Zahl sein';

  @override
  String get enterDurationMinutes => 'Gib eine Dauer in Minuten ein';

  @override
  String get durationPositive => 'Gib eine positive Minutenzahl ein';

  @override
  String minutesUnit(Object value) {
    return '$value Min.';
  }

  @override
  String secondsUnit(Object value) {
    return '$value Sek.';
  }

  @override
  String get summary => 'Zusammenfassung';

  @override
  String timeRound(Object time, Object round) {
    return 'Zeit: $time\nRunde: $round';
  }
}
