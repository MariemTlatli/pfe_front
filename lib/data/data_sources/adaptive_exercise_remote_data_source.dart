// lib/data/data_sources/adaptive_exercise_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:front/core/api/api_consumer.dart';
import 'package:front/data/models/exercise_model.dart';
import 'package:front/data/models/exercise_submission.dart';

/// Data Source pour les exercices adaptatifs avec SAINT+
class AdaptiveExerciseRemoteDataSource {
  final ApiConsumer apiConsumer;

  AdaptiveExerciseRemoteDataSource({required this.apiConsumer});

  /// Options avec timeout long pour la génération IA
  Options get _llmOptions => Options(
    receiveTimeout: const Duration(minutes: 30),
    sendTimeout: const Duration(minutes: 30),
  );

  /// Options standard pour les appels rapides
  Options get _standardOptions => Options(
    receiveTimeout: const Duration(seconds: 30000),
    sendTimeout: const Duration(seconds: 30000),
    connectTimeout: const Duration(seconds: 30000),
  );

  // ══════════════════════════════════════════════════════════════
  // GÉNÉRATION D'EXERCICES
  // ══════════════════════════════════════════════════════════════

  /// POST - Générer des exercices adaptatifs avec SAINT+
  ///
  /// Endpoint: POST /api/exercises/generate/{competence_id}
  /// Body: { "user_id": "...", "count": 3, "regenerate": false }
  Future<AdaptiveExercisesResponseModel> generateExercises({
    required String competenceId,
    required String userId,
    int count = 3,
    bool regenerate = false,
  }) async {
    try {
      print(
        '🎯 Génération exercices adaptatifs pour compétence $competenceId...',
      );
      print('   User: $userId, Count: $count, Regenerate: $regenerate');

      /*final response = await apiConsumer.post(
        'exercises/generate/$competenceId',
        data: {'user_id': userId, 'count': count, 'regenerate': regenerate},
        options: _llmOptions,
      );*/

      // 🧪 MODE MOCK - GÉNÉRATION LOCALE POUR TEST
      final response = {
        "status": "success",
        "competence_id": competenceId,
        "competence": {
          "id": competenceId,
          "name": "Compétence Simulation",
          "description": "Mode test sans appel API",
        },
        "exercises": [
          {
            "id": "69dece7328897c89ed8c0900",
            "type": "vrai_faux",
            "question": "La Terre est ronde.",
            "options": ["Vrai", "Faux"],
            "correct_answer": "Vrai",
            "hints": ["Pensez aux photos satellite !"],
            "difficulty": 0.2,
            "estimated_time": 30,
          },
          {
            "id": "69dece7328897c89ed8c0901",
            "type": "qcm",
            "question": "Quel est le moteur de rendu de Flutter ?",
            "options": ["Skia", "Gecko", "WebKit", "Blink"],
            "correct_answer": "Skia",
            "hints": ["C'est une bibliothèque graphique 2D."],
            "difficulty": 0.4,
            "estimated_time": 45,
          },
        ],
        "details": [
          {
            "id": "69dece7328897c89ed8c0900",
            "status": "generated",
            "type": "vrai_faux",
          },
          {
            "id": "69dece7328897c89ed8c0901",
            "status": "generated",
            "type": "qcm",
          },
        ],
        "lesson_titles": ["Introduction technique"],
        "saint_context": {
          "mastery": 0.65,
          "zone": "zpd",
          "optimal_difficulty": 0.35,
          "hint_level": "moyen",
          "engagement": "stable",
          "p_correct": 0.8,
        },
        "lessons_count": 1,
        "requested": count,
        "generated": 2,
        "errors": 0,
        "message": "Simulé localement",
      };

      print('✅ [MOCK] Exercices adaptatifs simulés');

      return AdaptiveExercisesResponseModel.fromJson(
        response,
      );
    } catch (e) {
      print('❌ Erreur génération exercices: $e');
      rethrow;
    }

  }

  // ══════════════════════════════════════════════════════════════
  // SOUMISSION DE RÉPONSE (NOUVEAU)
  // ══════════════════════════════════════════════════════════════

  /// POST - Soumettre une réponse avec données émotionnelles
  ///
  /// Endpoint: POST /api/response/submit
  /// Body: ExerciseSubmissionModel (JSON)
  ///
  /// Retourne:
  /// {
  ///   "status": "success",
  ///   "is_correct": true/false,
  ///   "decision": {
  ///     "action": "continue" | "next" | "adapt" | "pause",
  ///     "message": "...",
  ///     "encouragement": "...",
  ///     ...
  ///   },
  ///   "saint_result": {...},
  ///   "zpd_result": {...}
  /// }
  Future<Map<String, dynamic>> submitAnswer(
    ExerciseSubmissionModel submission,
  ) async {
    try {
      print('📤 Soumission de réponse...');
      print('   Exercise ID: ${submission.exerciseId}');
      print('   User ID: ${submission.userId}');
      print('   Answer: ${submission.answer}');
      print('   Time spent: ${submission.timeSpentSeconds}s');
      print('   Hints used: ${submission.hintsUsed}');
      print('   Emotion: ${submission.emotionData.dominantEmotion}');
      print('   Frustration: ${submission.emotionData.frustrationDetected}');

      final response = await apiConsumer.post(
        'responses/submit',
        data: submission.toJson(),
        options: _standardOptions,
      );

      print('✅ Réponse soumise avec succès');

      // Extraire les données de la réponse
      final result = response as Map<String, dynamic>;

      // Log des résultats
      final isCorrect = result['is_correct'] as bool? ?? false;
      final decision = result['decision'] as Map<String, dynamic>?;

      print('   ➜ Correct: $isCorrect');
      print('   ➜ Action: ${decision?['action']}');
      print('   ➜ Message: ${decision?['message']}');

      return result;
    } catch (e) {
      print('❌ Erreur soumission réponse: $e');
      rethrow;
    }
  }
}

