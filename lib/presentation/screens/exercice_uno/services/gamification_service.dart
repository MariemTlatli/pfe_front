// lib/presentation/screens/exercice_uno/services/gamification_service.dart
import 'package:dio/dio.dart';
import 'package:front/core/api/dio_factory.dart';

/// Service interact avec l'API de Gamification utilisant Dio.
class GamificationService {
  static final Dio _dio = DioFactory.createDio();

  /// Récupère les cartes pédagogiques d'un utilisateur.
  static Future<Response> fetchCards(String userId, {double difficulty = 0.5}) async {
    return await _dio.get('gamification/cartes/$userId', queryParameters: {
      'difficulty': difficulty,
    });
  }

  /// Récupère le statut des cartes spéciales.
  static Future<Response> fetchSpecialCards(String userId) async {
    return await _dio.get('gamification/special/$userId');
  }


  /// Récupère des cibles pour une carte +2.
  static Future<Response> fetchPlus2Targets(String userId, {int nombre = 3}) async {
    return await _dio.get('gamification/plus2/cibles/$userId', queryParameters: {
      'nombre': nombre,
    });
  }

  /// Utiliser une carte +2.

  static Future<Response> usePlus2(String fromUser, String toUser, {int nbExercices = 2}) async {
    return await _dio.post('gamification/plus2/utiliser', data: {
      'from_user_id': fromUser,
      'to_user_id': toUser,
      'nb_exercices': nbExercices,
    });
  }

  /// Utiliser une carte Skip.
  static Future<Response> useSkip(String userId, {int nbExercices = 2}) async {
    return await _dio.post('gamification/skip/$userId/utiliser', data: {
      'nb_exercices_a_annuler': nbExercices,
    });
  }

  /// Utiliser un Joker pour changer la difficulté.
  static Future<Response> useJoker(String userId, double newDifficulty) async {
    return await _dio.post('gamification/joker/$userId/utiliser', data: {
      'new_difficulty': newDifficulty,
    });
  }

  /// Utiliser une carte +4 pour obtenir 4 indices.
  static Future<Response> usePlus4(String userId, String exerciseId) async {
    // return await _dio.post('gamification/plus4/$userId/utiliser', data: {
    //   'exercise_id': exerciseId,
    // });

    // 🧪 MODE MOCK - GÉNÉRATION LOCALE DES INDICES
    await Future.delayed(const Duration(seconds: 1)); // Simuler un temps de calcul
    return Response(
      requestOptions: RequestOptions(path: 'mock_plus4'),
      statusCode: 200,
      data: {
        'success': true,
        'hints': [
          "💡 Premier indice : Regardez attentivement les mots-clés de la question.",
          "🔍 Deuxième indice : Éliminez les réponses qui semblent illogiques au premier abord.",
          "🧠 Troisième indice : Cette notion a été abordée dans la première leçon du chapitre.",
          "🎯 Quatrième indice : La bonne réponse est souvent la plus précise techniquement."
        ],
        'message': "Indices générés par l'IA avec succès !"
      },
    );
  }


  /// Réclamer une récompense de maîtrise.
  static Future<Response> claimMasteryReward(String userId, String competenceId) async {
    return await _dio.post('gamification/maitrise/attribuer', data: {
      'user_id': userId,
      'competence_id': competenceId,
    });
  }

  /// Utiliser une carte Reverse.
  static Future<Response> useReverse(String userId) async {
    return await _dio.post('gamification/reverse/$userId/utiliser');
  }
}




