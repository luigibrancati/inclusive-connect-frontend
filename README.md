# flutter_app_agy_firebase

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Build

### Android (Generate an APK)
You can build a standalone APK file that can be shared directly (via WhatsApp, Google Drive, etc.) and installed on any Android device.

Run the build command:
```bash
flutter build apk --release
```

Locate the file: The generated file will be at: `build/app/outputs/flutter-apk/app-release.apk`
Sharing: You can send this app-release.apk file to anyone. They might need to enable "Install from Unknown Sources" on their phone to install it.

### iOS (Requires macOS)
You cannot build an iOS application (IPA file) directly on Linux. Apple requires Xcode, which only runs on macOS, to compile and sign iOS apps.

Options:

- Use a Mac: If you have access to a Mac, clone your project there and run flutter build ios.
- Use a CI/CD Service: internal services like Codemagic, GitHub Actions, or Bitrise can build the iOS app in the cloud for you.
- For Testing: You can't just share a file like on Android. You typically must use TestFlight (requires an Apple Developer Account) or "Ad Hoc" distribution (requires registering device UDIDs).
