# Simplia Mobile

The Flutter companion to Simplia Web provides reporting, inventory checks, and accounting review. It uses the same backend API as the web app.

## Run locally

Install Flutter and the Android SDK, then configure the shared development runner and start the API. From the runner directory, launch the app with the script for your device.

```powershell
.\scripts\run-mobile-emulator.ps1
.\scripts\run-mobile-phone.ps1
```

The runner supplies the API URL. The phone script uses the configured development PC address, which the phone must be able to reach.

## Verify changes

From this repository, run:

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

Android displays **Simplia** and retains the existing application ID so signed updates can use the same installation. See the [architecture guide](documentation/ARCHITECTURE.md) for feature structure and the [deployment guide](documentation/DEPLOYMENT.md) for Android release builds.
