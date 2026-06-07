<p align="center">
  <img src="./assets/icon/app_icon.png" alt="WODRepLog" width="140">
</p>

<h1 align="center">WODRepLog</h1>

<p align="center">
  <a href="#quick-start">Quick Start</a>
  |
  <a href="#features">Features</a>
  |
  <a href="#recording-workflow">Recording Workflow</a>
  |
  <a href="#developer-notes">Developer Notes</a>
  |
  <a href="#release-builds">Release Builds</a>
</p>

WODRepLog is a Flutter workout logging app for setting CrossFit-style timers, recording workout proof videos with overlays, and tracking strength progress over time.

The app is built around a simple flow:

1. Set up a workout timer for AMRAP, EMOM, For Time, or Tabata.
2. Configure athlete, event, workout, countdown, and timer overlay details.
3. Record workout proof video with the configured overlay.
4. Log lifts and review PRs, estimated 1RM progress, and reps at weight.

## Quick Start

Install Flutter, fetch dependencies, and run the app:

```powershell
flutter pub get
flutter run
```

To launch a local Android emulator first:

```powershell
flutter emulators --launch Pixel_10
flutter run
```

The app uses Flutter `3.44.1` and Dart `3.12.1` as declared in `pubspec.yaml`.

## Features

- Branded main tabs for Timer, Log, and Stats.
- AMRAP, EMOM, For Time, and Tabata timer setup flows.
- Compact timer controls for minutes, seconds, rounds, work intervals, and rest intervals.
- Full-screen workout timer with pause, resume, and reset controls.
- Recording setup screen for athlete, event, workout, countdown, and timer overlay details.
- Camera recording view with workout metadata and timer overlays.
- Persisted Log tab settings so the latest recording setup is restored.
- Strength stats for lifts, including PR detection, estimated 1RM trends, and reps-at-weight history.
- Preset lift selector with Olympic lifts, powerlifting lifts, machine lifts, and common accessory movements.
- English and German localization support.

## Recording Workflow

WODRepLog keeps overlay setup separate from the camera screen. The Log tab is where recording details are configured before entering the camera view.

1. Enter athlete, event, workout, countdown, and timer overlay settings in the Log tab.
2. Tap `Recording`.
3. The latest settings are saved locally.
4. The camera view opens with the configured overlay.
5. Start and stop the recording from the camera view.

## Stats Workflow

The Stats tab tracks lift entries over time.

1. Add a lift from the preset lift dropdown.
2. Enter weight and reps.
3. Choose the displayed lift from the Stats dropdown.
4. Review current PR, estimated 1RM trend, and recent reps at weight.

## Developer Notes

Run the static analyzer:

```powershell
flutter analyze
```

Run tests:

```powershell
flutter test
```

Regenerate launcher icons after changing the icon assets:

```powershell
flutter pub run flutter_launcher_icons:main
```

Direct Dart and Flutter dependencies in `pubspec.yaml` are pinned to exact versions. `pubspec.lock` is committed so dependency resolution remains reproducible.

## Release Builds

For a local Windows release APK build, install:

- Flutter `3.44.1` or newer compatible with the pinned SDK constraints.
- A JDK with `keytool` on `PATH`.
- Android SDK with platform `android-36` and build tools installed.

Then run:

```powershell
pwsh ./scripts/build_android_apk.ps1
```

The script detects the Android SDK, updates `android/local.properties`, creates a debug keystore when no release keystore is configured, reads the visible version from `pubspec.yaml`, and computes the Android version code.

To build an Android App Bundle manually:

```powershell
flutter build appbundle
```

To build and install APKs from the bundle:

```powershell
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=build/app/outputs/apk/release/wodreplog.apks
bundletool install-apks --apks=build/app/outputs/apk/release/wodreplog.apks --device-id=DEVICE_ID
```

## Continuous Delivery

GitHub Actions does not change `pubspec.yaml` automatically. Update the visible `major.minor.patch` version when preparing a new release.

Pushing to `master` runs the **Release and Publish** workflow. If the checked-in version changed and no matching `v<major.minor.patch>` GitHub release or tag exists, the workflow builds and signs the app bundle, uploads it to the configured Google Play track, and creates the GitHub Release.

If a tag or release already exists but the Play upload did not run, manually run **Release and Publish** from `master` with `publish_existing_release` enabled.
