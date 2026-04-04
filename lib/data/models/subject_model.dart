class SubjectModel {
  final String id;
  final String domainId;
  final String domainName;
  final String name;
  final String? description;
  final int competencesCount;
  final bool hasCurriculum;
  final DateTime? createdAt;
  final bool isEnrolled;
  final double? progress;
  final String? enrollmentId;
  final String? status;

  SubjectModel({
    required this.id,
    required this.domainId,
    required this.domainName,
    required this.name,
    this.description,
    required this.competencesCount,
    required this.hasCurriculum,
    this.createdAt,
    this.isEnrolled = false,
    this.progress,
    this.enrollmentId,
    this.status,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      domainId: json['domain_id'] as String? ?? '',
      domainName: json['domain_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      competencesCount: json['competences_count'] as int? ?? 0,
      hasCurriculum: json['has_curriculum'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      isEnrolled: json['is_enrolled'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble(),
      enrollmentId: json['enrollment_id'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'domain_id': domainId,
      'domain_name': domainName,
      'name': name,
      'description': description,
      'competences_count': competencesCount,
      'has_curriculum': hasCurriculum,
      'created_at': createdAt?.toIso8601String(),
      'is_enrolled': isEnrolled,
      'progress': progress,
      'enrollment_id': enrollmentId,
      'status': status,
    };
  }

  SubjectModel copyWith({
    String? id,
    String? domainId,
    String? domainName,
    String? name,
    String? description,
    int? competencesCount,
    bool? hasCurriculum,
    DateTime? createdAt,
    bool? isEnrolled,
    double? progress,
    String? enrollmentId,
    String? status,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      domainId: domainId ?? this.domainId,
      domainName: domainName ?? this.domainName,
      name: name ?? this.name,
      description: description ?? this.description,
      competencesCount: competencesCount ?? this.competencesCount,
      hasCurriculum: hasCurriculum ?? this.hasCurriculum,
      createdAt: createdAt ?? this.createdAt,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      progress: progress ?? this.progress,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      status: status ?? this.status,
    );
  }
}
