// =============================================================================
// ADAPTIVE EXERCISE MODELS
// Modèles pour les exercices adaptatifs générés avec SAINT+
// =============================================================================

/// Contexte SAINT+ utilisé pour la génération
class SAINTContextModel {
  final double mastery;
  final String zone;
  final double optimalDifficulty;
  final String hintLevel;
  final List<String> recommendedExerciseTypes;
  final String engagement;
  final double pCorrect;

  SAINTContextModel({
    required this.mastery,
    required this.zone,
    required this.optimalDifficulty,
    required this.hintLevel,
    required this.recommendedExerciseTypes,
    required this.engagement,
    required this.pCorrect,
  });

  factory SAINTContextModel.fromJson(Map<String, dynamic> json) {
    final types = <String>[];
    if (json['recommended_exercise_types'] != null) {
      types.addAll((json['recommended_exercise_types'] as List).cast<String>());
    }

    return SAINTContextModel(
      mastery: (json['mastery'] as num?)?.toDouble() ?? 0.0,
      zone: json['zone'] as String? ?? 'zpd',
      optimalDifficulty: (json['optimal_difficulty'] as num?)?.toDouble() ?? 0.5,
      hintLevel: json['hint_level'] as String? ?? 'moyen',
      recommendedExerciseTypes: types,
      engagement: json['engagement'] as String? ?? 'inconnu',
      pCorrect: (json['p_correct'] as num?)?.toDouble() ?? 0.5,
    );
  }

  /// Niveau de maîtrise en pourcentage
  String get masteryPercentage => '${(mastery * 100).toStringAsFixed(0)}%';

  /// Probabilité de réussite en pourcentage
  String get pCorrectPercentage => '${(pCorrect * 100).toStringAsFixed(0)}%';
}

/// Compétence associée aux exercices
class ExerciseCompetenceModel {
  final String id;
  final String name;
  final String description;

  ExerciseCompetenceModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ExerciseCompetenceModel.fromJson(Map<String, dynamic> json) {
    return ExerciseCompetenceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

/// Détail d'un exercice généré
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

/// Exercice adaptatif
class AdaptiveExerciseModel {
  final String id;
  final String type;
  final double difficulty;
  final String question;
  final List<String> options;
  final List<String> hints;
  final int estimatedTime;
  final String? codeTemplate;
  final String? expectedOutput;

  AdaptiveExerciseModel({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.hints,
    required this.estimatedTime,
    this.codeTemplate,
    this.expectedOutput,
  });

  factory AdaptiveExerciseModel.fromJson(Map<String, dynamic> json) {
    final optionsList = <String>[];
    if (json['options'] != null) {
      optionsList.addAll((json['options'] as List).cast<String>());
    }

    final hintsList = <String>[];
    if (json['hints'] != null) {
      hintsList.addAll((json['hints'] as List).cast<String>());
    }

    return AdaptiveExerciseModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'qcm',
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.5,
      question: json['question'] as String? ?? '',
      options: optionsList,
      hints: hintsList,
      estimatedTime: json['estimated_time'] as int? ?? 60,
      codeTemplate: json['code_template'] as String?,
      expectedOutput: json['expected_output'] as String?,
    );
  }

  /// Difficulté en pourcentage
  String get difficultyPercentage => '${(difficulty * 100).toStringAsFixed(0)}%';

  /// Temps estimé formaté
  String get estimatedTimeFormatted {
    if (estimatedTime >= 60) {
      final minutes = estimatedTime ~/ 60;
      final seconds = estimatedTime % 60;
      return seconds > 0 ? '${minutes}min ${seconds}s' : '${minutes}min';
    }
    return '${estimatedTime}s';
  }

  /// Type d'exercice formaté
  String get typeFormatted {
    final typeNames = {
      'qcm': 'QCM',
      'qcm_multiple': 'QCM Multiple',
      'vrai_faux': 'Vrai / Faux',
      'texte_a_trous': 'Texte à trous',
      'code_completion': 'Complétion de code',
      'code_libre': 'Code libre',
      'debugging': 'Debugging',
      'projet_mini': 'Mini-projet',
    };
    return typeNames[type] ?? type;
  }

  /// Est-ce un exercice de code ?
  bool get isCodeExercise =>
      type == 'code_completion' || type == 'code_libre' || type == 'debugging';

  /// Est-ce un QCM ?
  bool get isQCM => type == 'qcm' || type == 'qcm_multiple' || type == 'vrai_faux';
}

/// Réponse complète de génération d'exercices
class AdaptiveExercisesResponseModel {
  final ExerciseCompetenceModel competence;
  final String competenceId;
  final List<AdaptiveExerciseModel> exercises;
  final List<ExerciseDetailModel> details;
  final List<String> lessonTitles;
  final SAINTContextModel saintContext;
  final int lessonsCount;
  final int requested;
  final int generated;
  final int errors;
  final String message;

  AdaptiveExercisesResponseModel({
    required this.competence,
    required this.competenceId,
    required this.exercises,
    required this.details,
    required this.lessonTitles,
    required this.saintContext,
    required this.lessonsCount,
    required this.requested,
    required this.generated,
    required this.errors,
    required this.message,
  });

  factory AdaptiveExercisesResponseModel.fromJson(Map<String, dynamic> json) {
    // Parser la compétence
    final competence = ExerciseCompetenceModel.fromJson(
      json['competence'] as Map<String, dynamic>? ?? {},
    );

    // Parser les exercices
    final exercisesList = <AdaptiveExerciseModel>[];
    if (json['exercises'] != null) {
      for (final ex in json['exercises'] as List) {
        exercisesList.add(
          AdaptiveExerciseModel.fromJson(ex as Map<String, dynamic>),
        );
      }
    }

    // Parser les détails
    final detailsList = <ExerciseDetailModel>[];
    if (json['details'] != null) {
      for (final detail in json['details'] as List) {
        detailsList.add(
          ExerciseDetailModel.fromJson(detail as Map<String, dynamic>),
        );
      }
    }

    // Parser les titres des leçons
    final lessonTitles = <String>[];
    if (json['lesson_titles'] != null) {
      lessonTitles.addAll((json['lesson_titles'] as List).cast<String>());
    }

    // Parser le contexte SAINT+
    final saintContext = SAINTContextModel.fromJson(
      json['saint_context'] as Map<String, dynamic>? ?? {},
    );

    return AdaptiveExercisesResponseModel(
      competence: competence,
      competenceId: json['competence_id'] as String? ?? '',
      exercises: exercisesList,
      details: detailsList,
      lessonTitles: lessonTitles,
      saintContext: saintContext,
      lessonsCount: json['lessons_count'] as int? ?? 0,
      requested: json['requested'] as int? ?? 0,
      generated: json['generated'] as int? ?? 0,
      errors: json['errors'] as int? ?? 0,
      message: json['message'] as String? ?? '',
    );
  }

  /// Vérifie si tous les exercices ont été générés
  bool get allGenerated => generated == requested && errors == 0;

  /// Récupère un exercice par index
  AdaptiveExerciseModel? getExercise(int index) {
    if (index >= 0 && index < exercises.length) {
      return exercises[index];
    }
    return null;
  }

  /// Premier exercice
  AdaptiveExerciseModel? get firstExercise =>
      exercises.isNotEmpty ? exercises.first : null;

  /// Temps total estimé
  int get totalEstimatedTime =>
      exercises.fold(0, (sum, ex) => sum + ex.estimatedTime);

  /// Temps total formaté
  String get totalEstimatedTimeFormatted {
    final total = totalEstimatedTime;
    if (total >= 60) {
      final minutes = total ~/ 60;
      final seconds = total % 60;
      return seconds > 0 ? '${minutes}min ${seconds}s' : '${minutes}min';
    }
    return '${total}s';
  }
}