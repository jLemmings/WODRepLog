![WODRepLog logo](assets/icon/app_icon.png)

# wodreplog

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Dependency management
- Direct Dart/Flutter dependencies in `pubspec.yaml` are pinned to exact versions.
- `pubspec.lock` is committed and CI installs with `flutter pub get --enforce-lockfile` to guarantee reproducible resolution.
- Renovate maintains dependency update PRs and lockfile maintenance on a weekly schedule (`renovate.json`).

## Dev
flutter emulators --launch Pixel_10
flutter run

## Build
- `pwsh ./scripts/build_android_apk.ps1`
- `flutter build appbundle`
- bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=build/app/outputs/apk/release/wodreplog.apks
- adb pair ip:port
- adb devices
- bundletool install-apks --apks=build/app/outputs/apk/release/wodreplog.apks --device-id=DEVICE_ID

### Local Android APK build
For a local Windows release APK build, install:

- Flutter `3.41.7` or newer (`pubspec.lock` currently resolves with Flutter `>=3.38.4`)
- A JDK with `keytool` on `PATH`
- Android SDK with platform `android-36` and build-tools installed

Then run:

```powershell
pwsh ./scripts/build_android_apk.ps1
```

The script:

- detects the Android SDK from `-AndroidSdkPath`, `ANDROID_HOME`, `ANDROID_SDK_ROOT`, or standard Windows SDK locations
- updates `android/local.properties` with `flutter.sdk` and `sdk.dir`
- creates `~/.android/debug.keystore` if no release keystore is configured
- reads the visible version from `pubspec.yaml`
- computes the Android version code from the visible version
- enables debug signing fallback for local release APK builds

### Continuous delivery
GitHub Actions never changes `pubspec.yaml` automatically. Update the visible `major.minor.patch` version when you want a new release. The Android version code is computed from that version as `major * 100000000 + minor * 1000000 + patch * 10000`.

Pushing to `master` runs the **Create Release** workflow. It compares the checked-in `major.minor.patch` version from `pubspec.yaml` with the previous `master` commit. If `major.minor.patch` changed and no `v<major.minor.patch>` GitHub release or tag exists, it creates a new GitHub Release. If only the build number changed, it skips release creation.

Publishing a GitHub Release runs the **Publish PROD** workflow, which validates the release tag matches the checked-in `major.minor.patch` version, builds a signed release app bundle, and publishes it to the configured Google Play track.


https://medium.com/lodgify-technology-blog/deploy-your-flutter-app-to-google-play-with-github-actions-f13a11c4492e
https://tbrgroup.software/flutter-build-and-deploy-android-apps-using-github-actions/

# Colours
Primary:
    Dark Charcoal (#1C1C1E)
    Graphite Gray (#2C2C2E)

Accent Colors:
    Electric Blue (#007AFF)
    Neon Green (#32FF7E)
    Fiery Orange (#FF9500)

Neutral Colors:
    Cool Gray (#8E8E93)
    Soft White (#EFEFF4)

Special Elements:
    Crimson Red (#FF3B30)

# Logo
flutter pub run flutter_launcher_icons:main
