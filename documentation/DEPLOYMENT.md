# Mobile deployment

The mobile app is a native Flutter client. Its deployment unit is a signed Android App Bundle or APK, not a server container.

Build each release against the HTTPS API URL for the target environment:

    flutter build appbundle --release --dart-define=API_BASE_URL=https://api.example.com

Use a unique version and build number in pubspec.yaml, sign the release with a protected keystore, then distribute through managed devices, a private app store, or the selected public store. Keep signing keys, API hostnames, and environment values out of source control. Test a release build on a physical device before rollout.
