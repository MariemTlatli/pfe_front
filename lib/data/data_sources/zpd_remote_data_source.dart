import 'package:front/core/api/api_consumer.dart';
import 'package:front/data/models/zpd_models.dart';

/// Data Source pour l'analyse ZPD enrichie avec SAINT+
class ZPDRemoteDataSource {
  final ApiConsumer apiConsumer;

  ZPDRemoteDataSource({required this.apiConsumer});

  /// POST - Analyser une compétence avec SAINT+
  /// 
  /// Endpoint: POST /api/zpd/competence/{competence_id}/analyze
  /// 
  /// Params:
  /// - userId (requis) : ID de l'utilisateur pour SAINT+
  /// - masteryLevel (optionnel) : Niveau de maîtrise manuel (0.0 à 1.0)
  /// - allMasteries (optionnel) : Map des maîtrises de toutes les compétences
  Future<CompetenceZPDAnalysisModel> analyzeCompetence({
    required String competenceId,
    required String userId,
    double? masteryLevel,
    Map<String, double>? allMasteries,
  }) async {
    try {
      print('📊 Analyse ZPD pour compétence $competenceId (user: $userId)...');

      // Construire le body avec tous les paramètres
      final data = <String, dynamic>{
        'user_id': userId,
      };

      // Ajouter mastery_level si fourni
      if (masteryLevel != null) {
        data['mastery_level'] = masteryLevel;
      }

      // Ajouter all_masteries si fourni
      if (allMasteries != null && allMasteries.isNotEmpty) {
        data['all_masteries'] = allMasteries;
      }

      final response = await apiConsumer.post(
        'zpd/competence/$competenceId/analyze',
        data: data,
      );

      print('✅ Analyse ZPD récupérée avec succès');

      return CompetenceZPDAnalysisModel.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ Erreur analyse ZPD: $e');
      rethrow;
    }
  }
}