import 'package:dio/dio.dart';

class ApiInspector extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('╔════════════════════════════════════════════════════════════════');
    print('║ REQUEST');
    print('╠════════════════════════════════════════════════════════════════');
    print('║ Method: ${options.method}');
    print('║ URL: ${options.baseUrl}${options.path}');
    print('║ Headers: ${options.headers}');
    print('║ Params: ${options.queryParameters}');
    if (options.data != null) {
      print('║ Body: ${options.data}');
    }
    print('╚════════════════════════════════════════════════════════════════');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('╔════════════════════════════════════════════════════════════════');
    print('║ RESPONSE');
    print('╠════════════════════════════════════════════════════════════════');
    print('║ Status Code: ${response.statusCode}');
    print(
      '║ URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}',
    );
    print('║ Data: ${response.data}');
    print('╚════════════════════════════════════════════════════════════════');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('╔════════════════════════════════════════════════════════════════');
    print('║ ERROR');
    print('╠════════════════════════════════════════════════════════════════');
    print('║ Type: ${err.type}');
    print('║ Message: ${err.message}');
    print('║ Status Code: ${err.response?.statusCode}');
    print('║ Data: ${err.response?.data}');
    print('╚════════════════════════════════════════════════════════════════');
    return handler.next(err);
  }
}
