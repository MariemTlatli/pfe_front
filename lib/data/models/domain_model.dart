class DomainModel {
  final String id;
  final String name;
  final String? description;
  final int subjectsCount;
  final DateTime? createdAt;

  DomainModel({
    required this.id,
    required this.name,
    this.description,
    required this.subjectsCount,
    this.createdAt,
  });

  factory DomainModel.fromJson(Map<String, dynamic> json) {
    return DomainModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      subjectsCount: json['subjects_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'subjects_count': subjectsCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
