class PrerequisiteModel {
  final String competenceId;
  final double strength;

  PrerequisiteModel({
    required this.competenceId,
    required this.strength,
  });

  factory PrerequisiteModel.fromJson(Map<String, dynamic> json) {
    return PrerequisiteModel(
      competenceId: json['competence_id'] as String? ?? '',
      strength: (json['strength'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competence_id': competenceId,
      'strength': strength,
    };
  }
}

class CompetenceModel {
  final String id;
  final String subjectId;
  final String code;
  final String name;
  final String description;
  final int level;
  final List<PrerequisiteModel> prerequisites;
  final Map<String, dynamic>? graphData;
  final double? baseDifficulty;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CompetenceModel({
    required this.id,
    required this.subjectId,
    required this.code,
    required this.name,
    required this.description,
    required this.level,
    this.prerequisites = const [],
    this.graphData,
    this.baseDifficulty,
    this.createdAt,
    this.updatedAt,
  });

  factory CompetenceModel.fromJson(Map<String, dynamic> json) {
    final prerequisitesList = (json['prerequisites'] as List?)
            ?.map((p) => PrerequisiteModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    return CompetenceModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      subjectId: json['subject_id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      prerequisites: prerequisitesList,
      graphData: json['graph_data'] as Map<String, dynamic>?,
      baseDifficulty:
          (json['difficulty_params']?['base_difficulty'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'code': code,
      'name': name,
      'description': description,
      'level': level,
      'prerequisites': prerequisites.map((p) => p.toJson()).toList(),
      'graph_data': graphData,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
