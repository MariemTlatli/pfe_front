class ExerciseDetailModel {
  final String id;
  final String status;
  final String type;
  final String? error;

  ExerciseDetailModel({
    required this.id,
    required this.status,
    required this.type,
    this.error,
  });

  factory ExerciseDetailModel.fromJson(Map<String, dynamic> json) {
    return ExerciseDetailModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'error',
      type: json['type'] as String? ?? 'qcm',
      error: json['error'] as String?,
    );
  }

  bool get isGenerated => status == 'generated';
}
