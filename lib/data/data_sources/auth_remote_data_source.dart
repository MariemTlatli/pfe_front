import '../../core/api/api_consumer.dart';
import '../../core/api/endpoints.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

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
  Future<UserModel> getUserProfile(String userId);
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
    var user_id = response['data']['user']['user_id'];
    final res = await apiConsumer.get(
      'gamification/special_cards_init/$user_id',
    );
    print("*******************res******************");
    print(res);
    print("*******************res******************");

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

  @override
  Future<UserModel> getUserProfile(String userId) async {
    final response = await apiConsumer.get('auth/profile/$userId');
    return UserModel.fromJson(response);
  }
}
