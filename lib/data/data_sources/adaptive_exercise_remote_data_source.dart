// lib/data/data_sources/adaptive_exercise_remote_data_source.dart

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:front/core/api/api_consumer.dart';
import 'package:front/data/models/exercise_model.dart';
import 'package:front/data/models/exercise_submission.dart';
import 'package:front/presentation/screens/exercises/adaptive_exercise_page/mock_data.dart';

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
    double? difficulty,
    List<String>? exerciseTypes,
  }) async {
    try {
      print(
        '🎯 Génération exercices adaptatifs pour compétence $competenceId...',
      );
      print(
        '   User: $userId, Count: $count, Regenerate: $regenerate, Difficulty: $difficulty, Types: $exerciseTypes',
      );

      final data = {
        'user_id': userId,
        'count': count,
        'regenerate': regenerate,
      };

      if (difficulty != null) data['difficulty'] = difficulty;
      if (exerciseTypes != null) data['exercise_types'] = exerciseTypes;

      final response = await apiConsumer.post(
        'exercises/generate/$competenceId',
        data: data,
        options: _llmOptions,
      );
      // 🔹 Instanciation directe
      // final AdaptiveExercisesResponseModel mockResponse =
      //     AdaptiveExercisesResponseModel.fromJson(mockAdaptiveExercisesJson);

      // final response = {"exercises": exercises};
      print('✅ Exercices adaptatifs générés avec succès');

      return AdaptiveExercisesResponseModel.fromJson(
        response,
      );
      // return mockResponse;
      
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
      if (decision != null) {
        print('   ➜ Action: ${decision['action']}');
        print('   ➜ Message: ${decision['message']}');

        // 🎴 Récupération de la NUMBER CARD
        if (decision.containsKey('looted_card')) {
          final lootedCard = decision['looted_card'];
          print(
            '   🎁 CARTE OBTENUE (LOOTED): Couleur "${lootedCard['color']}", Numéro "${lootedCard['number']}"',
          );
        }
      }

      return result;

      // ══════════════════════════════════════════════════════════════
      // GAMIFICATION ÉMOTIONNELLE
      // ══════════════════════════════════════════════════════════════

  
    } catch (e) {
      print('❌ Erreur soumission réponse: $e');
      rethrow;
    }
}
/// POST - Attribue carte Inversion (Happy >= 5)
  Future<Map<String, dynamic>> attribuerInversion(String userId) async {
    try {
      final res = await apiConsumer.post(
        'gamification/inversion/$userId/attribuer-par-emotion',
      );
      return res as Map<String, dynamic>;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// POST - Attribue carte Joker (Sad >= 5)
  Future<Map<String, dynamic>> attribuerJoker(String userId) async {
    try {
      final res = await apiConsumer.post(
        'gamification/joker/$userId/attribuer-par-emotion',
      );
      return res as Map<String, dynamic>;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // ══════════════════════════════════════════════════════════════
  // NUMBER CARDS (CRAFTING)
  // ══════════════════════════════════════════════════════════════

  /// GET - Récupère l'inventaire de cartes chiffrées
  Future<Map<String, dynamic>> getNumberCardsInventory(String userId) async {
    try {
      final response = await apiConsumer.get(
        'gamification/number-cards/$userId',
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      return {"success": false, "inventory": {}};
    }
  }

  /// POST - Demande à fusionner deux cartes du même type
  Future<Map<String, dynamic>> mergeNumberCards(
    String userId,
    String color,
    int baseNumber,
  ) async {
    try {
      final response = await apiConsumer.post(
        'gamification/number-cards/$userId/merge',
        data: {"color": color, "base_number": baseNumber},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      return {"success": false, "message": "Erreur réseau."};
    }
  }
}
