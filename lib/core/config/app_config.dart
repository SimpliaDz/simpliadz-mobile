class AppConfig {
  const AppConfig._();

  /// Override with --dart-define=API_BASE_URL=http://localhost:5278.
  /// The default reaches a server running on the Android emulator host.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5278',
  );
}
