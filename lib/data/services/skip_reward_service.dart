import 'dart:math';
import 'package:front/core/api/api_consumer.dart';

/// Service pour gérer l'attribution aléatoire de la carte Skip en cas d'échec.
class SkipRewardService {
  final ApiConsumer _api;

  SkipRewardService(this._api);

  /// Vérifie si l'utilisateur gagne un Skip de consolation.
  /// Se déclenche aléatoirement sur une réponse incorrecte.
  Future<bool> checkAndReward({
    required String userId,
    required bool isCorrect,
  }) async {
    var x = Random().nextDouble();
    print(x);
    // Condition : Échec et chance aléatoire (30%)
    if (!isCorrect && x > 0.6) {
      try {
        final response = await _api.post("/gamification/skip/$userId/attribuer");
        if (response != null && response['success'] == true) {
          print("🛡️ [Consolation] Carte Skip attribuée !");
          return true;
        }
      } catch (e) {
        print("❌ [Consolation] Erreur attribution Skip: $e");
      }
    }
    return false;
  }
}
