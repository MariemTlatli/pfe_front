abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({required String message, String? code})
    : super(message: message, code: code);
}

class ServerException extends AppException {
  final int statusCode;

  ServerException({
    required String message,
    this.statusCode = 500,
    String? code,
  }) : super(message: message, code: code);
}

class UnauthorizedException extends AppException {
  UnauthorizedException({required String message, String? code})
    : super(message: message, code: code);
}

class NotFoundException extends AppException {
  NotFoundException({required String message, String? code})
    : super(message: message, code: code);
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  ValidationException({required String message, this.errors, String? code})
    : super(message: message, code: code);
}

class CacheException extends AppException {
  CacheException({required String message, String? code})
    : super(message: message, code: code);
}

class UnknownException extends AppException {
  UnknownException({required String message, String? code})
    : super(message: message, code: code);
}
