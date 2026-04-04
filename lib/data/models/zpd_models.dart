// =============================================================================
// ZPD MODELS
// Modèles pour l'analyse ZPD enrichie avec SAINT+
// =============================================================================

import 'package:flutter/material.dart';

/// Paramètres de difficulté d'une compétence
class ZPDDifficultyParamsModel {
  final double baseDifficulty;
  final int masteryExercises;
  final int minExercises;
  final int weight;

  ZPDDifficultyParamsModel({
    required this.baseDifficulty,
    required this.masteryExercises,
    required this.minExercises,
    required this.weight,
  });

  factory ZPDDifficultyParamsModel.fromJson(Map<String, dynamic> json) {
    return ZPDDifficultyParamsModel(
      baseDifficulty: (json['base_difficulty'] as num?)?.toDouble() ?? 0.0,
      masteryExercises: (json['mastery_exercises'] as num?)?.toInt() ?? 5,
      minExercises: (json['min_exercises'] as num?)?.toInt() ?? 3,
      weight: (json['weight'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_difficulty': baseDifficulty,
      'mastery_exercises': masteryExercises,
      'min_exercises': minExercises,
      'weight': weight,
    };
  }
}

/// Prérequis d'une compétence
class ZPDPrerequisiteDetailsModel {
  final String competenceId;
  final String code;
  final String name;
  final double mastery;
  final bool satisfied;

  ZPDPrerequisiteDetailsModel({
    required this.competenceId,
    required this.code,
    required this.name,
    required this.mastery,
    required this.satisfied,
  });

  factory ZPDPrerequisiteDetailsModel.fromJson(Map<String, dynamic> json) {
    return ZPDPrerequisiteDetailsModel(
      competenceId: json['competence_id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mastery: (json['mastery'] as num?)?.toDouble() ?? 0.0,
      satisfied: json['satisfied'] as bool? ?? false,
    );
  }
}

/// Informations sur les prérequis
class ZPDPrerequisitesModel {
  final bool allSatisfied;
  final int count;
  final List<ZPDPrerequisiteDetailsModel> details;
  final double globalScore;

  ZPDPrerequisitesModel({
    required this.allSatisfied,
    required this.count,
    required this.details,
    required this.globalScore,
  });

  factory ZPDPrerequisitesModel.fromJson(Map<String, dynamic> json) {
    final detailsList = <ZPDPrerequisiteDetailsModel>[];
    if (json['details'] != null) {
      for (final detail in json['details'] as List) {
        detailsList.add(
          ZPDPrerequisiteDetailsModel.fromJson(detail as Map<String, dynamic>),
        );
      }
    }

    return ZPDPrerequisitesModel(
      allSatisfied: json['all_satisfied'] as bool? ?? true,
      count: (json['count'] as num?)?.toInt() ?? 0,
      details: detailsList,
      globalScore: (json['global_score'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

/// Seuils ZPD
class ZPDThresholdsModel {
  final double learning;
  final double mastered;

  ZPDThresholdsModel({
    required this.learning,
    required this.mastered,
  });

  factory ZPDThresholdsModel.fromJson(Map<String, dynamic> json) {
    return ZPDThresholdsModel(
      learning: (json['learning'] as num?)?.toDouble() ?? 0.4,
      mastered: (json['mastered'] as num?)?.toDouble() ?? 0.85,
    );
  }
}

/// Métriques d'anomalies
class SAINTAnomalyModel {
  final bool hasAnomaly;
  final List<dynamic> flags;
  final String severity;

  SAINTAnomalyModel({
    required this.hasAnomaly,
    required this.flags,
    required this.severity,
  });

  factory SAINTAnomalyModel.fromJson(Map<String, dynamic> json) {
    return SAINTAnomalyModel(
      hasAnomaly: json['has_anomaly'] as bool? ?? false,
      flags: json['flags'] as List? ?? [],
      severity: json['severity'] as String? ?? 'none',
    );
  }
}

/// Métriques de confiance
class SAINTConfidenceModel {
  final String level;
  final int nInteractions;
  final double score;

  SAINTConfidenceModel({
    required this.level,
    required this.nInteractions,
    required this.score,
  });

  factory SAINTConfidenceModel.fromJson(Map<String, dynamic> json) {
    return SAINTConfidenceModel(
      level: json['level'] as String? ?? 'faible',
      nInteractions: (json['n_interactions'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Métriques d'engagement
class SAINTEngagementModel {
  final String description;
  final Map<String, dynamic> factors;
  final String level;
  final double score;

  SAINTEngagementModel({
    required this.description,
    required this.factors,
    required this.level,
    required this.score,
  });

  factory SAINTEngagementModel.fromJson(Map<String, dynamic> json) {
    return SAINTEngagementModel(
      description: json['description'] as String? ?? '',
      factors: json['factors'] as Map<String, dynamic>? ?? {},
      level: json['level'] as String? ?? 'inconnu',
      score: (json['score'] as num?)?.toDouble() ?? 0.5,
    );
  }
}

/// Tentatives estimées
class SAINTEstimatedAttemptsModel {
  final String label;
  final int value;

  SAINTEstimatedAttemptsModel({
    required this.label,
    required this.value,
  });

  factory SAINTEstimatedAttemptsModel.fromJson(Map<String, dynamic> json) {
    return SAINTEstimatedAttemptsModel(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num?)?.toInt() ?? 3,
    );
  }
}

/// Probabilité de besoin d'indice
class SAINTHintProbabilityModel {
  final String description;
  final String level;
  final double probability;

  SAINTHintProbabilityModel({
    required this.description,
    required this.level,
    required this.probability,
  });

  factory SAINTHintProbabilityModel.fromJson(Map<String, dynamic> json) {
    return SAINTHintProbabilityModel(
      description: json['description'] as String? ?? '',
      level: json['level'] as String? ?? 'moyen',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.5,
    );
  }
}

/// Métriques SAINT+ complètes
class SAINTMetricsModel {
  final SAINTAnomalyModel anomaly;
  final SAINTConfidenceModel confidence;
  final SAINTEngagementModel engagement;
  final SAINTEstimatedAttemptsModel estimatedAttempts;
  final SAINTHintProbabilityModel hintProbability;
  final double pCorrect;

  SAINTMetricsModel({
    required this.anomaly,
    required this.confidence,
    required this.engagement,
    required this.estimatedAttempts,
    required this.hintProbability,
    required this.pCorrect,
  });

  factory SAINTMetricsModel.fromJson(Map<String, dynamic> json) {
    return SAINTMetricsModel(
      anomaly: SAINTAnomalyModel.fromJson(
        json['anomaly'] as Map<String, dynamic>? ?? {},
      ),
      confidence: SAINTConfidenceModel.fromJson(
        json['confidence'] as Map<String, dynamic>? ?? {},
      ),
      engagement: SAINTEngagementModel.fromJson(
        json['engagement'] as Map<String, dynamic>? ?? {},
      ),
      estimatedAttempts: SAINTEstimatedAttemptsModel.fromJson(
        json['estimated_attempts'] as Map<String, dynamic>? ?? {},
      ),
      hintProbability: SAINTHintProbabilityModel.fromJson(
        json['hint_probability'] as Map<String, dynamic>? ?? {},
      ),
      pCorrect: (json['p_correct'] as num?)?.toDouble() ?? 0.5,
    );
  }
}

/// Analyse ZPD complète d'une compétence
class CompetenceZPDAnalysisModel {
  final String competenceId;
  final String code;
  final String name;
  final String description;
  final int level;
  final double masteryLevel;
  final String rawZone;
  final String effectiveZone;
  final String zoneLabel;
  final bool isReady;
  final double optimalDifficulty;
  final List<String> recommendedExerciseTypes;
  final int priorityScore;
  final ZPDDifficultyParamsModel difficultyParams;
  final ZPDPrerequisitesModel prerequisites;
  final ZPDThresholdsModel thresholds;
  final SAINTMetricsModel saintMetrics;

  CompetenceZPDAnalysisModel({
    required this.competenceId,
    required this.code,
    required this.name,
    required this.description,
    required this.level,
    required this.masteryLevel,
    required this.rawZone,
    required this.effectiveZone,
    required this.zoneLabel,
    required this.isReady,
    required this.optimalDifficulty,
    required this.recommendedExerciseTypes,
    required this.priorityScore,
    required this.difficultyParams,
    required this.prerequisites,
    required this.thresholds,
    required this.saintMetrics,
  });

  factory CompetenceZPDAnalysisModel.fromJson(Map<String, dynamic> json) {
    final exerciseTypes = <String>[];
    if (json['recommended_exercise_types'] != null) {
      exerciseTypes.addAll(
        (json['recommended_exercise_types'] as List).cast<String>(),
      );
    }

    return CompetenceZPDAnalysisModel(
      competenceId: json['competence_id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      masteryLevel: (json['mastery_level'] as num?)?.toDouble() ?? 0.0,
      rawZone: json['raw_zone'] as String? ?? 'frustration',
      effectiveZone: json['effective_zone'] as String? ?? 'frustration',
      zoneLabel: json['zone_label'] as String? ?? '',
      isReady: json['is_ready'] as bool? ?? false,
      optimalDifficulty: (json['optimal_difficulty'] as num?)?.toDouble() ?? 0.1,
      recommendedExerciseTypes: exerciseTypes,
      priorityScore: (json['priority_score'] as num?)?.toInt() ?? 0,
      difficultyParams: ZPDDifficultyParamsModel.fromJson(
        json['difficulty_params'] as Map<String, dynamic>? ?? {},
      ),
      prerequisites: ZPDPrerequisitesModel.fromJson(
        json['prerequisites'] as Map<String, dynamic>? ?? {},
      ),
      thresholds: ZPDThresholdsModel.fromJson(
        json['thresholds'] as Map<String, dynamic>? ?? {},
      ),
      saintMetrics: SAINTMetricsModel.fromJson(
        json['saint_metrics'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Helpers

  /// Niveau de maîtrise en pourcentage
  String get masteryPercentage => '${(masteryLevel * 100).toStringAsFixed(0)}%';

  /// Couleur de la zone
  Color get zoneColor {
    switch (effectiveZone) {
      case 'mastered':
        return Colors.green;
      case 'zpd':
        return Colors.blue;
      case 'frustration':
      default:
        return Colors.orange;
    }
  }

  /// Icône de la zone
  IconData get zoneIcon {
    switch (effectiveZone) {
      case 'mastered':
        return Icons.check_circle;
      case 'zpd':
        return Icons.school;
      case 'frustration':
      default:
        return Icons.warning;
    }
  }

  /// Texte du bouton selon la zone
  String get actionButtonText {
    switch (effectiveZone) {
      case 'mastered':
        return 'Réviser';
      case 'zpd':
        return 'Commencer les exercices';
      case 'frustration':
      default:
        return 'Réviser les bases';
    }
  }
}