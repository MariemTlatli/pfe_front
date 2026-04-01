import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              keyCipherAlgorithm:
                  KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
              storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
              resetOnError: true,
            ),
            iOptions: const IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  // Token Management
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      print('[SecureStorage] Error saving token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      print('[SecureStorage] Error reading token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      print('[SecureStorage] Error deleting token: $e');
    }
  }

  // Refresh Token Management
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      print('[SecureStorage] Error saving refresh token: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      print('[SecureStorage] Error reading refresh token: $e');
      return null;
    }
  }

  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      print('[SecureStorage] Error deleting refresh token: $e');
    }
  }

  // User Data Management
  Future<void> saveUserData({
    required String userId,
    required String username,
    required String email,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _userIdKey, value: userId),
        _storage.write(key: _usernameKey, value: username),
        _storage.write(key: _emailKey, value: email),
      ]);
    } catch (e) {
      print('[SecureStorage] Error saving user data: $e');
    }
  }

  Future<Map<String, String?>> getUserData() async {
    try {
      final userId = await _storage.read(key: _userIdKey);
      final username = await _storage.read(key: _usernameKey);
      final email = await _storage.read(key: _emailKey);

      return {'userId': userId, 'username': username, 'email': email};
    } catch (e) {
      print('[SecureStorage] Error reading user data: $e');
      return {};
    }
  }

  // Clear All Data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('[SecureStorage] Error clearing all data: $e');
    }
  }
}
