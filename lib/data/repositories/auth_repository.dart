import '../../core/local_storage/secure_storage_service.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<String?> getToken();

  Future<bool> isLoggedIn();

  Future<Map<String, String?>> getUserData();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.register(
      username: username,
      email: email,
      password: password,
    );

    // Save token and user data
    await secureStorage.saveToken(response.accessToken);
    if (response.refreshToken != null) {
      await secureStorage.saveRefreshToken(response.refreshToken!);
    }
    await secureStorage.saveUserData(
      userId: response.user.userId,
      username: response.user.username,
      email: response.user.email,
    );

    return response;
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );

    // Save token and user data
    await secureStorage.saveToken(response.accessToken);
    if (response.refreshToken != null) {
      await secureStorage.saveRefreshToken(response.refreshToken!);
    }
    await secureStorage.saveUserData(
      userId: response.user.userId,
      username: response.user.username,
      email: response.user.email,
    );

    return response;
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await secureStorage.clearAll();
    }
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.getToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<Map<String, String?>> getUserData() async {
    return await secureStorage.getUserData();
  }
}
