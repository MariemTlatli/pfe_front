import 'package:front/core/api/api_consumer.dart';

/// Service pour gérer l'attribution automatique de la carte +2.
/// Seuil de difficulté : 0.6 à 1.0 (Exercice considéré comme difficile).
class PlusTwoService {
  final ApiConsumer _api;

  PlusTwoService(this._api);

  /// Vérifie si l'utilisateur mérite un bonus +2 et l'attribue via le backend.
  /// Retourne true si l'attribution a réussi.
  Future<bool> checkAndReward({
    required String userId,
    required double difficulty,
    required bool isCorrect,
  }) async {
    // Condition : Succès sur un exercice difficile (diff >= 0.6)
    if (isCorrect && difficulty >= 0.6 && difficulty <= 1.0) {
      try {
        final response = await _api.post("/gamification/plus2/$userId/attribuer");
        if (response != null && response['success'] == true) {
          print("✨ [Bonus] +2 carte attribuée pour réussite difficile !");
          return true;
        }
      } catch (e) {
        print("❌ [Bonus] Erreur attribution +2: $e");
      }
    }
    return false;
  }
}
