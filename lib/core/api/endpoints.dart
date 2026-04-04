class Endpoints {
  static const String baseUrl = 'http://192.168.1.18:5000/api/';

  // Auth Endpoints
  static const String register = 'auth/register';
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String refresh = 'auth/refresh';
  static const String profile = 'auth/profile';

  // User Endpoints
  static const String getUser = 'user/{id}';
  static const String updateUser = 'user/{id}';
  static const String deleteUser = 'user/{id}';

  // Discovery Endpoints
  static const String domains = 'domains';
  static const String userSubjects = 'user-subjects';
  static const String subjects = 'subjects';
  static const String responses = 'responses';

  // Generic method to build URL with parameters
  static String buildUrl(String endpoint, {Map<String, String>? parameters}) {
    String url = endpoint;
    parameters?.forEach((key, value) {
      url = url.replaceAll('{$key}', value);
    });
    return url;
  }
}
