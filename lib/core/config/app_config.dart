class AppConfig {
  const AppConfig({required this.apiBaseUri});

  factory AppConfig.fromEnvironment() {
    const rawUrl = String.fromEnvironment(
      'OPENBANK_API_URL',
      defaultValue: 'http://127.0.0.1:4566',
    );
    return AppConfig(apiBaseUri: Uri.parse(rawUrl));
  }

  final Uri apiBaseUri;
}
