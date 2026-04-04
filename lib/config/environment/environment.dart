class Environment {
  static const String appName = 'Auth App';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://192.168.1.18:5000/api/'; // À changer
  static const String apiTimeout = '30'; // secondes

  // Feature Flags
  static const bool debugApiLogs = true;
  static const bool showApiInspector = true;

  // Localization
  static const String defaultLanguage = 'fr';
  static const List<String> supportedLanguages = ['en', 'fr'];
}
