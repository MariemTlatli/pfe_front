import 'subject_model.dart';

class EnrollmentModel {
  final String enrollmentId;
  final String userId;
  final String subjectId;
  final DateTime enrolledAt;
  final String status;
  final double progress;
  final String? currentCompetenceId;
  final List<String> completedCompetences;
  final Map<String, dynamic>? stats;

  EnrollmentModel({
    required this.enrollmentId,
    required this.userId,
    required this.subjectId,
    required this.enrolledAt,
    required this.status,
    required this.progress,
    this.currentCompetenceId,
    this.completedCompetences = const [],
    this.stats,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    final completedList = (json['completed_competences'] as List?)?.cast<String>() ?? [];

    return EnrollmentModel(
      enrollmentId: json['enrollment_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      subjectId: json['subject_id'] as String? ?? '',
      enrolledAt: json['enrolled_at'] != null
          ? DateTime.parse(json['enrolled_at'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'active',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      currentCompetenceId: json['current_competence_id'] as String?,
      completedCompetences: completedList,
      stats: json['stats'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrollment_id': enrollmentId,
      'user_id': userId,
      'subject_id': subjectId,
      'enrolled_at': enrolledAt.toIso8601String(),
      'status': status,
      'progress': progress,
      'current_competence_id': currentCompetenceId,
      'completed_competences': completedCompetences,
      'stats': stats,
    };
  }
}

class UserSubjectDetailModel {
  final EnrollmentModel enrollment;
  final SubjectModel subject;
  final Map<String, dynamic> learningPath;
  final Map<String, dynamic> progress;

  UserSubjectDetailModel({
    required this.enrollment,
    required this.subject,
    required this.learningPath,
    required this.progress,
  });

  factory UserSubjectDetailModel.fromJson(Map<String, dynamic> json) {
    return UserSubjectDetailModel(
      enrollment: EnrollmentModel.fromJson(
        json.containsKey('enrollment') 
            ? json['enrollment'] as Map<String, dynamic> 
            : json
      ),
      subject: SubjectModel.fromJson(json['subject'] as Map<String, dynamic>),
      learningPath: json['learning_path'] as Map<String, dynamic>? ?? {},
      progress: json['progress'] as Map<String, dynamic>? ?? {},
    );
  }
}


class EnrollmentResponseModel {
  final String enrollmentId;
  final String subjectId;
  final DateTime enrolledAt;
  final String message;

  EnrollmentResponseModel({
    required this.enrollmentId,
    required this.subjectId,
    required this.enrolledAt,
    required this.message,
  });

  factory EnrollmentResponseModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentResponseModel(
      enrollmentId: json['enrollment_id'] as String? ?? '',
      subjectId: json['subject_id'] as String? ?? '',
      enrolledAt: json['enrolled_at'] != null
          ? DateTime.parse(json['enrolled_at'] as String)
          : DateTime.now(),
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrollment_id': enrollmentId,
      'subject_id': subjectId,
      'enrolled_at': enrolledAt.toIso8601String(),
      'message': message,
    };
  }
}

class BulkEnrollResponseModel {
  final List<Map<String, dynamic>> enrolled;
  final List<String> alreadyEnrolled;
  final int total;
  final String message;

  BulkEnrollResponseModel({
    required this.enrolled,
    required this.alreadyEnrolled,
    required this.total,
    required this.message,
  });

  factory BulkEnrollResponseModel.fromJson(Map<String, dynamic> json) {
    return BulkEnrollResponseModel(
      enrolled: (json['enrolled'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      alreadyEnrolled:
          (json['already_enrolled'] as List?)?.cast<String>() ?? [],
      total: json['total'] as int? ?? 0,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrolled': enrolled,
      'already_enrolled': alreadyEnrolled,
      'total': total,
      'message': message,
    };
  }
}
