import 'package:dio/dio.dart';
import '../../config/localization/localization_service.dart';
import '../errors/exceptions.dart';
import '../errors/handle_errors.dart';
import 'api_consumer.dart';

class HttpConsumer implements ApiConsumer {
  final Dio dio;
  final AppLocalizations locale;

  HttpConsumer({required this.dio, required this.locale});

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw ErrorHandler.handle(e, locale);
    } catch (e) {
      throw ErrorHandler.handle(e, locale);
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw ErrorHandler.handle(e, locale);
    } catch (e) {
      throw ErrorHandler.handle(e, locale);
    }
  }

  @override
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw ErrorHandler.handle(e, locale);
    } catch (e) {
      throw ErrorHandler.handle(e, locale);
    }
  }

  @override
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw ErrorHandler.handle(e, locale);
    } catch (e) {
      throw ErrorHandler.handle(e, locale);
    }
  }

  @override
  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw ErrorHandler.handle(e, locale);
    } catch (e) {
      throw ErrorHandler.handle(e, locale);
    }
  }

  dynamic _handleResponse(Response response) {
    if (response.statusCode == null) {
      throw UnknownException(message: 'Unknown error occurred');
    }

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      throw ErrorHandler.handle(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        ),
        locale,
      );
    }
  }
}
