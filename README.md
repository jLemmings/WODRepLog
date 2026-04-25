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
flutter emulators --launch Pixel_8
flutter run

## Build
- `pwsh ./scripts/build_android_apk.ps1 -BuildNumber 240036 -BuildName 0.0.24+36`
- `flutter build appbundle`
- bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=build/app/outputs/apk/release/wodreplog.apks
- adb pair ip:port
- adb devices
- bundletool install-apks --apks=build/app/outputs/apk/release/wodreplog.apks --device-id=DEVICE_ID

### Local Android APK build
For a local Windows release APK build, install:

- Flutter `3.35.6`
- A JDK with `keytool` on `PATH`
- Android SDK with platform `android-35` and build-tools installed

Then run:

```powershell
pwsh ./scripts/build_android_apk.ps1 -BuildNumber 240036 -BuildName 0.0.24+36
```

The script:

- detects the Android SDK from `-AndroidSdkPath`, `ANDROID_HOME`, `ANDROID_SDK_ROOT`, or standard Windows SDK locations
- updates `android/local.properties` with `flutter.sdk` and `sdk.dir`
- creates `~/.android/debug.keystore` if no release keystore is configured
- enables debug signing fallback for local release APK builds

### Continuous delivery
Pushing to the `master` branch triggers the **Build and Publish** GitHub Actions workflow, which automatically increments the build number in `pubspec.yaml`, commits the change, builds a signed release app bundle, and publishes it to the Google Play internal testing track using the configured service account credentials.


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
