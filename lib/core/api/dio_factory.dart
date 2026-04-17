import 'package:dio/dio.dart';
import 'api_inspector.dart';
import 'endpoints.dart';

class DioFactory {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 3000), // 🔥 important
        receiveTimeout: const Duration(seconds: 3000),
        sendTimeout: const Duration(seconds: 3000),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(ApiInspector());
    return dio;
  }
}
