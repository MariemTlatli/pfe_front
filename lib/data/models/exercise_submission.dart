/// Modèle qui regroupe TOUTES les données à envoyer lors de la soumission
/// d'un exercice pour mise à jour du profil + adaptation.
class ExerciseSubmissionModel {
  // ── Identification ────────────────────────────
  final String exerciseId;
  final String competenceId;
  final String userId;

  // ── Réponse de l'apprenant ────────────────────
  final String answer;
  final List<String>? multipleAnswers; // Pour QCM multiple
  final bool isCorrect; // Sera calculé par le backend ou frontend

  // ── Données de performance ────────────────────
  final int timeSpentSeconds;
  final int hintsUsed;
  final int attemptNumber;

  // ── Données émotionnelles ─────────────────────
  final EmotionSubmissionData emotionData;

  // ── Données ZPD/SAINT+ ────────────────────────
  final String currentZpdZone; // 'mastered', 'zpd', 'frustration'
  final double currentMasteryLevel; // 0.0 à 1.0

  ExerciseSubmissionModel({
    required this.exerciseId,
    required this.competenceId,
    required this.userId,
    required this.answer,
    this.multipleAnswers,
    required this.isCorrect,
    required this.timeSpentSeconds,
    required this.hintsUsed,
    this.attemptNumber = 1,
    required this.emotionData,
    required this.currentZpdZone,
    required this.currentMasteryLevel,
  });

  /// Convertit en JSON pour l'envoi au backend Flask
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'exercise_id': exerciseId,
      'competence_id': competenceId,
      'answer': answer,
      if (multipleAnswers != null && multipleAnswers!.isNotEmpty)
        'multiple_answers': multipleAnswers,
      'is_correct': isCorrect,
      'time_spent_seconds': timeSpentSeconds,
      'hints_used': hintsUsed,
      'attempt_number': attemptNumber,
      'emotion_data': emotionData.toJson(),
      'current_zpd_zone': currentZpdZone,
      'current_mastery_level': currentMasteryLevel,
    };
  }

  @override
  String toString() {
    return 'ExerciseSubmissionModel('
        'exercise: $exerciseId, '
        'emotion: ${emotionData.dominantEmotion}, '
        'zpd: $currentZpdZone, '
        'time: ${timeSpentSeconds}s'
        ')';
  }
}

/// Modèle pour les données émotionnelles
class EmotionSubmissionData {
  final String dominantEmotion;
  final double confidence;
  final List<EmotionCaptureData> emotionHistory;
  final bool frustrationDetected;
  final double averageConfidence;

  EmotionSubmissionData({
    required this.dominantEmotion,
    required this.confidence,
    required this.emotionHistory,
    required this.frustrationDetected,
    required this.averageConfidence,
  });

  /// Factory pour créer à partir des captures du provider
  factory EmotionSubmissionData.fromEmotionCaptures(
    List<EmotionCaptureData> captures,
  ) {
    if (captures.isEmpty) {
      return EmotionSubmissionData(
        dominantEmotion: 'neutral',
        confidence: 0.5,
        emotionHistory: [],
        frustrationDetected: false,
        averageConfidence: 0.5,
      );
    }

    // Calculer l'émotion dominante (la plus fréquente)
    final emotionCounts = <String, int>{};
    double totalConfidence = 0.0;
    bool hasFrustration = false;

    for (final capture in captures) {
      emotionCounts[capture.emotion] = (emotionCounts[capture.emotion] ?? 0) + 1;
      totalConfidence += capture.confidence;

      // Détection frustration (fear, angry, sad combinés)
      if (['fear', 'angry', 'sad'].contains(capture.emotion.toLowerCase())) {
        hasFrustration = true;
      }
    }

    final dominantEmotion = emotionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return EmotionSubmissionData(
      dominantEmotion: dominantEmotion,
      confidence: captures.last.confidence, // Dernière capture
      emotionHistory: captures,
      frustrationDetected: hasFrustration,
      averageConfidence: totalConfidence / captures.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dominant_emotion': dominantEmotion,
      'confidence': confidence,
      'emotion_history': emotionHistory.map((e) => e.toJson()).toList(),
      'frustration_detected': frustrationDetected,
      'average_confidence': averageConfidence,
    };
  }
}

/// Modèle pour une capture émotionnelle individuelle
class EmotionCaptureData {
  final String emotion;
  final double confidence;
  final DateTime timestamp;

  EmotionCaptureData({
    required this.emotion,
    required this.confidence,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'emotion': emotion,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}