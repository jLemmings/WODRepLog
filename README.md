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

## Dev
flutter emulators --launch Pixel_8_API_35
flutter run

## Build
- flutter build appbundle
- bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=build/app/outputs/apk/release/wodreplog.apks
- adb pair ip:port
- adb devices
- bundletool install-apks --apks=build/app/outputs/apk/release/wodreplog.apks --device-id=DEVICE_ID

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