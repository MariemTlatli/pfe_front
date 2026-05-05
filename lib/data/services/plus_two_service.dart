import 'package:front/core/api/api_consumer.dart';

/// Service gérant l'attribution de la carte +2 selon la performance de l'apprenant.
/// 
/// Logique : Attribuer +2 si l'exercice est réussi ET si sa difficulté est entre 0.6 et 1.0.
class PlusTwoService {
  final ApiConsumer apiConsumer;

  PlusTwoService({required this.apiConsumer});

  /// Vérifie les conditions et appelle l'API backend pour attribuer la carte.
  Future<void> checkAndAttribute({
    required String userId,
    required double difficulty,
    required bool isCorrect,
  }) async {
    // Condition demandée : Réussite + Difficulté entre 0.6 et 1.0
    if (isCorrect && difficulty >= 0.6 && difficulty <= 1.0) {
      try {
        final response = await apiConsumer.post("plus2/$userId/attribuer");
        
        if (response != null && response['success'] == true) {
          print("🎁 [PlusTwoService] Carte +2 attribuée à l'utilisateur $userId");
        }
      } catch (e) {
        print("⚠️ [PlusTwoService] Échec de l'attribution : $e");
      }
    }
  }
}
