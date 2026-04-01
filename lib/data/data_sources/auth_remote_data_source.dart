import '../../core/api/api_consumer.dart';
import '../../core/api/endpoints.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
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
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer apiConsumer;

  AuthRemoteDataSourceImpl({required this.apiConsumer});

  @override
  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await apiConsumer.post(
      Endpoints.register,
      data: {'username': username, 'email': email, 'password': password},
    );

    return AuthResponseModel.fromJson(response['data'] ?? response);
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiConsumer.post(
      Endpoints.login,
      data: {'email': email, 'password': password},
    );

    return AuthResponseModel.fromJson(response['data'] ?? response);
  }

  @override
  Future<void> logout() async {
    await apiConsumer.post(Endpoints.logout);
  }
}
