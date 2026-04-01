import 'package:dio/dio.dart';
import 'package:front/core/api/api_consumer.dart';
import 'package:front/data/models/curriculum_models.dart';

class CurriculumRemoteDataSource {
  final ApiConsumer apiConsumer;

  CurriculumRemoteDataSource({required this.apiConsumer});

  /// Options avec timeout long pour les opérations LLM
  Options get _llmOptions => Options(
        receiveTimeout: const Duration(minutes: 30),
        sendTimeout: const Duration(minutes: 30),
        connectTimeout: const Duration(minutes: 30),
      );

  /// GET - Récupérer un curriculum existant
  Future<CurriculumResponseModel> getCurriculum({
    required String subjectId,
  }) async {
    try {
      print('📥 Récupération du curriculum pour $subjectId...');

      final response = await apiConsumer.get(
        'curriculum/subject/$subjectId',
      );

      print('✅ Curriculum récupéré avec succès');

      return CurriculumResponseModel.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ Erreur récupération curriculum: $e');
      rethrow;
    }
  }

  /// POST - Génère le curriculum complet (2 requêtes successives)
  Future<CurriculumResponseModel> generateCurriculum({
    required String subjectId,
    bool regenerate = false,
  }) async {
    try {
      // Étape 1 : Générer le curriculum (compétences)
      print('🚀 Étape 1: Génération du curriculum pour $subjectId...');

      await apiConsumer.post(
        'curriculum/generate/$subjectId',
        queryParameters: regenerate ? {'regenerate': 'true'} : null,
        options: _llmOptions,
      );

      print('✅ Étape 1 terminée: curriculum/generate done');

      // Étape 2 : Régénérer les prérequis
      print('🚀 Étape 2: Régénération des prérequis pour $subjectId...');

      final response = await apiConsumer.post(
        'curriculum/regenerate-prerequisites/$subjectId',
        options: _llmOptions,
      );

      print('✅ Étape 2 terminée: regenerate-prerequisites done');

      return CurriculumResponseModel.fromJson(
        response as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ Erreur génération curriculum: $e');
      rethrow;
    }
  }
}