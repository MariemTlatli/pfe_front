// =============================================================================
// CURRICULUM MODELS
// Modèles pour la génération et affichage du curriculum (compétences + graphe)
// =============================================================================

/// Paramètres de difficulté d'une compétence
class DifficultyParamsModel {
  final double baseDifficulty;
  final int masteryExercises;
  final int minExercises;

  DifficultyParamsModel({
    required this.baseDifficulty,
    required this.masteryExercises,
    required this.minExercises,
  });

  factory DifficultyParamsModel.fromJson(Map<String, dynamic> json) {
    return DifficultyParamsModel(
      baseDifficulty: (json['base_difficulty'] as num?)?.toDouble() ?? 0.0,
      masteryExercises: json['mastery_exercises'] as int? ?? 5,
      minExercises: json['min_exercises'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_difficulty': baseDifficulty,
      'mastery_exercises': masteryExercises,
      'min_exercises': minExercises,
    };
  }
}

/// Prérequis d'une compétence (version enrichie pour curriculum)
class CurriculumPrerequisiteModel {
  final String competenceId;
  final String competenceCode;
  final String competenceName;
  final double strength;

  CurriculumPrerequisiteModel({
    required this.competenceId,
    required this.competenceCode,
    required this.competenceName,
    required this.strength,
  });

  factory CurriculumPrerequisiteModel.fromJson(Map<String, dynamic> json) {
    return CurriculumPrerequisiteModel(
      competenceId: json['competence_id'] as String? ?? '',
      competenceCode: json['competence_code'] as String? ?? '',
      competenceName: json['competence_name'] as String? ?? '',
      strength: (json['strength'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competence_id': competenceId,
      'competence_code': competenceCode,
      'competence_name': competenceName,
      'strength': strength,
    };
  }
}

/// Compétence dans le curriculum (version pour affichage introductif)
class CurriculumCompetenceModel {
  final String id;
  final String subjectId;
  final String code;
  final String name;
  final String description;
  final int level;
  final DifficultyParamsModel difficultyParams;
  final List<CurriculumPrerequisiteModel> prerequisites;
  final bool hasLessons;        // ← NOUVEAU
  final int lessonsCount;       // ← NOUVEAU

  CurriculumCompetenceModel({
    required this.id,
    required this.subjectId,
    required this.code,
    required this.name,
    required this.description,
    required this.level,
    required this.difficultyParams,
    this.prerequisites = const [],
    this.hasLessons = false,      // ← NOUVEAU
    this.lessonsCount = 0,        // ← NOUVEAU
  });
CurriculumCompetenceModel copyWith({
    String? id,
    String? subjectId,
    String? code,
    String? name,
    String? description,
    int? level,
    DifficultyParamsModel? difficultyParams,
    List<CurriculumPrerequisiteModel>? prerequisites,
    bool? hasLessons,
    int? lessonsCount,
  }) {
    return CurriculumCompetenceModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      difficultyParams: difficultyParams ?? this.difficultyParams,
      prerequisites: prerequisites ?? this.prerequisites,
      hasLessons: hasLessons ?? this.hasLessons,
      lessonsCount: lessonsCount ?? this.lessonsCount,
    );
  }

  factory CurriculumCompetenceModel.fromJson(Map<String, dynamic> json) {
    // Parser les prérequis
    final prerequisitesList = <CurriculumPrerequisiteModel>[];
    if (json['prerequisites'] != null) {
      for (final p in json['prerequisites'] as List) {
        prerequisitesList.add(
          CurriculumPrerequisiteModel.fromJson(p as Map<String, dynamic>),
        );
      }
    }

    // Parser difficulty_params
    DifficultyParamsModel difficultyParams;
    if (json['difficulty_params'] != null) {
      difficultyParams = DifficultyParamsModel.fromJson(
        json['difficulty_params'] as Map<String, dynamic>,
      );
    } else {
      difficultyParams = DifficultyParamsModel(
        baseDifficulty: 0.0,
        masteryExercises: 5,
        minExercises: 3,
      );
    }

    return CurriculumCompetenceModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      subjectId: json['subject_id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      difficultyParams: difficultyParams,
      prerequisites: prerequisitesList,
      hasLessons: json['has_lessons'] as bool? ?? false,      // ← NOUVEAU
      lessonsCount: json['lessons_count'] as int? ?? 0,       // ← NOUVEAU
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
      'difficulty_params': difficultyParams.toJson(),
      'prerequisites': prerequisites.map((p) => p.toJson()).toList(),
      'has_lessons': hasLessons,        // ← NOUVEAU
      'lessons_count': lessonsCount,    // ← NOUVEAU
    };
  }
  

  /// Vérifie si cette compétence a des prérequis
  bool get hasPrerequisites => prerequisites.isNotEmpty;

  /// Retourne le nombre de prérequis
  int get prerequisitesCount => prerequisites.length;

  /// Retourne la difficulté formatée en pourcentage
  String get difficultyPercentage =>
      '${(difficultyParams.baseDifficulty * 100).toStringAsFixed(0)}%';
}
/// Statistiques du curriculum
class CurriculumStatsModel {
  final int totalCompetences;
  final int totalEdges;
  final int maxLevel;
  final int rootNodes;
  final int leafNodes;
  final int longestPath;
  final bool isValidDag;

  CurriculumStatsModel({
    required this.totalCompetences,
    required this.totalEdges,
    required this.maxLevel,
    required this.rootNodes,
    required this.leafNodes,
    required this.longestPath,
    required this.isValidDag,
  });

  factory CurriculumStatsModel.fromJson(Map<String, dynamic> json) {
    return CurriculumStatsModel(
      totalCompetences: json['total_competences'] as int? ?? 0,
      totalEdges: json['total_edges'] as int? ?? 0,
      maxLevel: json['max_level'] as int? ?? 0,
      rootNodes: json['root_nodes'] as int? ?? 0,
      leafNodes: json['leaf_nodes'] as int? ?? 0,
      longestPath: json['longest_path'] as int? ?? 0,
      isValidDag: json['is_valid_dag'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_competences': totalCompetences,
      'total_edges': totalEdges,
      'max_level': maxLevel,
      'root_nodes': rootNodes,
      'leaf_nodes': leafNodes,
      'longest_path': longestPath,
      'is_valid_dag': isValidDag,
    };
  }
}

/// Réponse complète de génération du curriculum
class CurriculumResponseModel {
  final List<CurriculumCompetenceModel> competences;
  final CurriculumStatsModel stats;
  final String? message;

  CurriculumResponseModel({
    required this.competences,
    required this.stats,
    this.message,
  });

  factory CurriculumResponseModel.fromJson(Map<String, dynamic> json) {
    // Parser les compétences
    final competencesList = <CurriculumCompetenceModel>[];
    if (json['competences'] != null) {
      for (final c in json['competences'] as List) {
        competencesList.add(
          CurriculumCompetenceModel.fromJson(c as Map<String, dynamic>),
        );
      }
    }
    
    // Parser les stats
    CurriculumStatsModel stats;
    if (json['stats'] != null) {
      stats = CurriculumStatsModel.fromJson(
        json['stats'] as Map<String, dynamic>,
      );
    } else {
      stats = CurriculumStatsModel(
        totalCompetences: competencesList.length,
        totalEdges: 0,
        maxLevel: 0,
        rootNodes: 0,
        leafNodes: 0,
        longestPath: 0,
        isValidDag: false,
      );
    }

    return CurriculumResponseModel(
      competences: competencesList,
      stats: stats,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'competences': competences.map((c) => c.toJson()).toList(),
      'stats': stats.toJson(),
      'message': message,
    };
  }

  /// Retourne les compétences triées par niveau
  List<CurriculumCompetenceModel> get competencesByLevel {
    final sorted = List<CurriculumCompetenceModel>.from(competences);
    sorted.sort((a, b) => a.level.compareTo(b.level));
    return sorted;
  }

  /// Retourne les compétences d'un niveau spécifique
  List<CurriculumCompetenceModel> getCompetencesAtLevel(int level) {
    return competences.where((c) => c.level == level).toList();
  }

  /// Retourne les compétences racines (sans prérequis)
  List<CurriculumCompetenceModel> get rootCompetences {
    return competences.where((c) => !c.hasPrerequisites).toList();
  }
}