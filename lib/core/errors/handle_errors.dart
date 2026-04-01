import 'package:dio/dio.dart';
import '../../config/localization/localization_service.dart';
import 'exceptions.dart';
import 'error_model.dart';

class ErrorHandler {
  static AppException handle(dynamic error, AppLocalizations locale) {
    print('[ErrorHandler] Handling error: $error');

    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error, locale);
    }

    return UnknownException(message: locale.unknownError);
  }

  static AppException _handleDioError(
    DioException error,
    AppLocalizations locale,
  ) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkException(message: locale.networkError, code: 'TIMEOUT');

      case DioExceptionType.badResponse:
        return _handleBadResponse(error, locale);

      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request cancelled',
          code: 'CANCELLED',
        );

      case DioExceptionType.unknown:
        if (error.error is NetworkException) {
          return error.error as NetworkException;
        }
        return NetworkException(message: locale.networkError, code: 'UNKNOWN');

      default:
        return UnknownException(message: locale.unknownError);
    }
  }

  static AppException _handleBadResponse(
    DioException error,
    AppLocalizations locale,
  ) {
    final statusCode = error.response?.statusCode ?? 0;
    final data = error.response?.data;

    ErrorModel? errorModel;
    if (data is Map<String, dynamic>) {
      errorModel = ErrorModel.fromJson(data);
    }

    String message = errorModel?.message ?? 'An error occurred';

    switch (statusCode) {
      case 400:
        message = errorModel?.message ?? locale.validationError;
        return ValidationException(
          message: message,
          errors: errorModel?.errors,
          code: 'VALIDATION_ERROR',
        );

      case 401:
        message = locale.unauthorizedError;
        return UnauthorizedException(message: message, code: 'UNAUTHORIZED');

      case 404:
        message = locale.notFoundError;
        return NotFoundException(message: message, code: 'NOT_FOUND');

      case 500:
        message = locale.serverError;
        return ServerException(
          message: message,
          statusCode: statusCode,
          code: 'SERVER_ERROR',
        );

      default:
        return ServerException(
          message: message,
          statusCode: statusCode,
          code: 'BAD_RESPONSE',
        );
    }
  }
}
