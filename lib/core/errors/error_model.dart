class ErrorModel {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ErrorModel({required this.message, this.code, this.statusCode, this.errors});

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      message: json['message'] ?? 'An error occurred',
      code: json['code']?.toString(),
      statusCode: json['status_code'],
      errors: json['errors'] is Map ? json['errors'] : null,
    );
  }

  @override
  String toString() => message;
}
