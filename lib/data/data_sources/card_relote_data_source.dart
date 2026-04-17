import 'package:front/core/api/api_consumer.dart';
import 'package:front/data/models/special_cards_model.dart';

import '../models/card_api_model.dart';

class CardRemote_dataSource {
  final ApiConsumer apiConsumer;

  CardRemote_dataSource({required this.apiConsumer});

  Future<List<CardApiModel>> fetchInitialCards({
    required String userId,
    required double difficulty,
    required int nbCartes,
  }) async {
    try {
      // apiConsumer retourne déjà List<dynamic> parsée
     final responseData = await apiConsumer.get(
        'gamification/cartes/$userId',
        queryParameters: {
          'difficulty': difficulty,
        },
      );

      // Vérification de sécurité
      if (responseData is! List) {
        print(responseData);
        throw Exception(
          'Format de réponse inattendu: ${responseData.runtimeType}',
        );
      }

      // Mapping direct vers CardApiModel
      return responseData
          .map((item) => CardApiModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Gère les erreurs réseau ou de parsing
      if (e is Exception) rethrow;
      throw Exception('Erreur lors du chargement des cartes: $e');
    }
  }

  Future<SpecialCardsStatus> fetchSpecialCardsStatus(String userId) async {
    // ✅ Option A : user_id dans l'URL
    final response = await apiConsumer.get(
      'gamification/special_cards/$userId',
    );

    // Si apiConsumer parse automatiquement le JSON :
    if (response is Map<String, dynamic>) {
      print(response);
      return SpecialCardsStatus.fromJson(response);
    }

    // Si response a un body String à parser :
    // final data = jsonDecode(response.body);
    // return SpecialCardsStatus.fromJson(data);

    throw Exception('Format de réponse inattendu');
  }
}
